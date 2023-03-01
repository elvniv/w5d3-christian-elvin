require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database 
include Singleton 

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end

end

class User
    attr_accessor :fname, :lname
    def initialize(options) 
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def self.find_by_id(id) 
        user = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT 
                * 
            FROM 
                users
            WHERE 
                id = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT
                * 
            FROM 
                users
            WHERE 
                fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def authored_questions
        Question.find_by_author_id(@id)
    end

    def authored_replies
        Reply.find_by_user_id(@id)
    end

    def self.followed_questions
        QuestionFollows.followed_questions_for_user_id(@id) 
    end
end

class Question
    attr_accessor :title, :body, :user_id
     def initialize(options) 
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def self.find_by_id(id) 
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM 
                questions 
            WHERE 
                id = ? 
        SQL
        return nil unless question.length > 0
        Question.new(question.first)
    end

    def self.find_by_author_id(user_id) 
        questions = QuestionsDatabase.execute(<<-SQL, user_id)
            SELECT
                *
            FROM 
                questions 
            WHERE 
                user_id = ?
        SQL
        return nil unless questions.length > 0 
        questions.map {|question| Question.new(question)}
    end

    def author
        User.find_by_id(@user_id)
    end

    def replies 
        Reply.find_by_question_id(@id)
    end

    def followers
        QuestionFollows.followers_for_question_id(@id)
    end
end

class Reply
    attr_accessor :question_id, :parent_id, :user_id, :body
    def initialize(options) 
        @id = options['id']
        @question_id = options['question_id']
        @parent_id = options['parent_id']
        @user_id = options['user_id']
        @body = options['body']
    end

    def self.find_by_user_id(user_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id) 
        SELECT
            * 
        FROM 
            replies 
        WHERE 
            user_id = ?
        SQL
        return nil unless replies.length > 0 
        replies.map {|reply| Reply.new(reply)}
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id) 
        SELECT
            * 
        FROM 
            replies 
        WHERE 
            question_id = ?
        SQL
        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply)}
    end

    def author
        User.find_by_id(@user)
    end

    def question 
        Question.find_by_id(@question_id)
    end

    def parent_reply 
        Reply.find_by_id(@parent_id)
    end

    def child_replies 
        replies = QuestionsDatabase.instance.execute(<<-SQL, @id) 
        SELECT
            * 
        FROM 
            replies 
        WHERE 
            parent_id = ? 
        SQL
        return nil unless replies.length > 0 
        replies.map {|reply| Reply.new(reply)}
    end
end

class QuestionFollows
    attr_accessor :question_id, :user_id
    def initialize(options) 
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

    def self.find_by_id(id) 
        question_follows = QuestionsDatabase.instance.execute(<<-SQL, id) 
        SELECT
            * 
        FROM 
            question_follows
        WHERE 
            id = ? 
        SQL
        return nil unless question_follows.length > 0
        question_follows.map {|question| QuestionFollows.new(question)}
    end

    def self.followers_for_question_id(question_id)
        followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT 
            * 
        FROM 
            users
        JOIN 
            question_follows ON users.id = question_follows.user_id 
        WHERE 
            question_follows.question_id = ? 
        SQL
        return nil unless followers.length > 0
        followers.map {|follower| User.new(follower)}
    end

    def self.followed_questions_for_user_id(user_id) 
        followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
            *
        FROM 
            questions 
        JOIN 
            question_follows on questions.id = question_follows.question_id 
        WHERE 
            question_follows.user_id = ? 
        SQL
        return nil unless followed_questions.length > 0
        followed_questions.map {|followed| User.new(followed)}
    end

    def most_followed_questions(n) 
        followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n) 
        SELECT
            * 
        FROM 
            questions 
        JOIN
            question_follows ON question_id = question_follows.question_id
        GROUP BY
            questions.id 
        ORDER BY 
            COUNT(question_follows.user_id) DESC 
        LIMIT 
            ? 
        SQL
        return nil unless followed_questions.length > 0
        followed_questions.map {|question| Question.new(question)}
    end
end