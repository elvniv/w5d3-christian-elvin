PRAGMA foreign_keys = ON;


DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body VARCHAR(255) NOT NULL,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);


CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    body VARCHAR(255) NOT NULL,
    parent_reply INTEGER,
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (parent_reply) REFERENCES replies(id)
);



CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO 
    users (fname, lname) 
VALUES 
    ('Christian', 'Espinosa'),
    ('Elvin','Atwine')
;

INSERT INTO
    questions (title, body, user_id)
VALUES
    ('First president', 'Who was the first president',
     (  SELECT id FROM users WHERE fname = 'Christian'  ) )
;

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname='Christian'),
    (SELECT id FROM questions WHERE title='First president')
    )
;

INSERT INTO
    replies (question_id, user_id, body, parent_reply)
VALUES
    (
        (SELECT id FROM questions WHERE title = 'First president'),
        (SELECT id FROM users WHERE fname='Christian' ),
        ('George Washington'),
        (NULL)
    )
;

INSERT INTO
    question_likes (question_id, user_id)
VALUES
    (
        (SELECT id FROM questions WHERE title = 'First president'),
        (SELECT id FROM users WHERE fname='Elvin' )
    )
;