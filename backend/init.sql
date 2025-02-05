-- UTF-8 Encoding Settings
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET collation_connection = 'utf8mb4_unicode_ci';


-- Database Creation
CREATE DATABASE IF NOT EXISTS palink;
USE palink;

-- Basic Settings
SET FOREIGN_KEY_CHECKS=0;

-- ✅ Create 'user' table
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `userId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `accountId` VARCHAR(255),
  `name` VARCHAR(255),
  `password` VARCHAR(255),
  `age` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'aicharacter' table
DROP TABLE IF EXISTS `aicharacter`;
CREATE TABLE `aicharacter` (
  `characterId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `aiName` VARCHAR(255),
  `description` TEXT,
  `difficultyLevel` INT
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'conversation' table
DROP TABLE IF EXISTS `conversation`;
CREATE TABLE `conversation` (
  `conversationId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `day` DATETIME,
  `userId` INT,
  `characterId` INT,
  FOREIGN KEY (`userId`) REFERENCES `user`(`userId`),
  FOREIGN KEY (`characterId`) REFERENCES `aicharacter`(`characterId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'message' table
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `messageId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `conversationId` INT,
  `sender` BOOLEAN,
  `messageText` TEXT,
  `timestamp` DATETIME,
  FOREIGN KEY (`conversationId`) REFERENCES `conversation`(`conversationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'tip' table
DROP TABLE IF EXISTS `tip`;
CREATE TABLE `tip` (
  `tipId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `tipText` TEXT,
  `messageId` INT,
  FOREIGN KEY (`messageId`) REFERENCES `message`(`messageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'feedback' table
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `feedbackId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `feedbackText` TEXT,
  `finalLikingLevel` INT,
  `totalRejectionScore` INT,
  `day` DATETIME,
  `conversationId` INT,
  FOREIGN KEY (`conversationId`) REFERENCES `conversation`(`conversationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'collection' table
DROP TABLE IF EXISTS `usercollection`;
CREATE TABLE `usercollection` (
  `userId` INT,
  `characterId` INT,
  `addedDate` DATETIME,
  PRIMARY KEY (`userId`, `characterId`),
  FOREIGN KEY (`userId`) REFERENCES `user`(`userId`),
  FOREIGN KEY (`characterId`) REFERENCES `aicharacter`(`characterId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ✅ Create 'emotion' table
DROP TABLE IF EXISTS `emotion`;
CREATE TABLE `emotion` (
  `emotionId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `emotionType` VARCHAR(255),
  `vibrationPattern` VARCHAR(255),
  `backgroundColor` VARCHAR(255),
  `messageId` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'mindset' table
CREATE TABLE `mindset` (
  `mindsetId` int NOT NULL AUTO_INCREMENT,
  `mindsetText` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`mindsetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ✅ Create 'liking' table
DROP TABLE IF EXISTS `liking`;
CREATE TABLE `liking` (
  `likingId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `userId` INT,
  `characterId` INT,
  `likingLevel` INT,
  `messageId` INT,
  FOREIGN KEY (`userId`) REFERENCES `user`(`userId`),
  FOREIGN KEY (`characterId`) REFERENCES `aicharacter`(`characterId`),
  FOREIGN KEY (`messageId`) REFERENCES `message`(`messageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'rejection' table
DROP TABLE IF EXISTS `rejection`;
CREATE TABLE `rejection` (
  `rejectionId` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `userId` INT,
  `characterId` INT,
  `rejectionLevel` INT,
  `messageId` INT,
  `rejectionText` TEXT,
  FOREIGN KEY (`userId`) REFERENCES `user`(`userId`),
  FOREIGN KEY (`characterId`) REFERENCES `aicharacter`(`characterId`),
  FOREIGN KEY (`messageId`) REFERENCES `message`(`messageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Create 'aiResponse' table
DROP TABLE IF EXISTS `AIResponses`;
CREATE TABLE `AIResponses` (
  `aiMessage` INT NOT NULL PRIMARY KEY,
  `text` TEXT NOT NULL,
  `feeling` TEXT,
  `affinity_score` INT,
  `rejection_score` JSON,
  `rejection_content` JSON,
  `userMessage` TEXT,
  `final_rejection_score` INT,
  `final_affinity_score` INT,
  `conversation_id` INT,
  FOREIGN KEY (`aiMessage`) REFERENCES `message`(`messageId`),
  FOREIGN KEY (`conversation_id`) REFERENCES `conversation`(`conversationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ✅ Insert initial data
INSERT INTO mindset (mindsetId, mindsetText) VALUES
(1,'Trying to please everyone will make you lose yourself. It is important to prioritize yourself. This is necessary to protect our mental and emotional health.'),
(2,'If you are afraid of speaking in front of people, remember that everyone feels nervous at first. Confidence can be built through repeated practice and small successes.'),
(3,'To build confidence, it is important to find your strengths and develop them. This enhances self-efficacy and helps you become a better version of yourself.'),
(4,'Mistakes are part of the growth process. You can learn and improve through mistakes. Accepting this can help you build better relationships.'),
(5,'Taking care of yourself is very important. A healthy mind and body are necessary for maintaining healthy relationships with others.'),
(6,'Positive self-talk boosts confidence and helps maintain a positive attitude even in difficult situations. This also has a positive impact on interpersonal relationships.'),
(7,'Expressing your thoughts and emotions is very important. Do not be afraid of others’ reactions, and be honest in expressing yourself. This helps to reveal your true self and deepen relationships.'),
(8,'The opinions and evaluations of others do not determine your worth. It is important to recognize your own value and self-esteem. This helps maintain a healthy self-image.'),
(9,'Holding on to the past and staying in an unhappy relationship does not help. It is important to acknowledge the past and make decisions that are necessary for the present and future.'),
(10,'If I am comfortable, others will also feel comfortable. It is important to acknowledge yourself by saying "It’s okay."'),
(11,'When you maintain a relaxed mind, that energy is conveyed to others. This helps form natural and comfortable relationships.'),
(12,'The thoughts and opinions of others are their concerns, and they are beyond my control. It is more important to focus on my own emotions and thoughts. This helps protect my mental health.'),
(13,'The judgments of others are temporary and can change. Do not dwell too much on them and follow your own path. This helps in continuous self-development and the pursuit of happiness.'),
(14,'Trying to impress everyone will only exhaust you. It is more important to focus on relationships that matter to you. This helps use your energy efficiently.'),
(15,'I am the master of my own life. It is important to make my own decisions without being swayed by others’ opinions. This leads to true freedom and self-respect.'),
(16,'We have the right to choose how we spend our time and energy. Saying no is a legitimate choice to protect our needs and priorities. This allows us to lead our lives more proactively.'),
(17,'In conflict situations, it is important to seek solutions together rather than blaming the other person. This helps resolve issues more efficiently and strengthens relationships.'),
(18,'Saying "yes" to every request ignores my own will and needs. It is important to know my limits and say no appropriately. This protects my self-esteem and helps maintain healthy relationships.'),
(19,'Saying no properly does not ruin relationships. On the contrary, honest conversations can deepen relationships. Respecting each other’s boundaries is important.'),
(20,'Being able to say no is a sign of confidence. Knowing and expressing your limits is true courage. This helps clearly communicate your boundaries to others.'),
(21,'Saying no can become more natural through practice. If you start with small things, you can gradually say no to bigger things naturally. This strengthens decision-making skills.'),
(22,'Do not feel guilty when saying no for a legitimate reason. Protecting your boundaries is natural. Excessive guilt only makes you suffer. Saying no is a way of respecting yourself.'),
(23,'When refusing a request, offering an alternative can help the other person accept it more easily. This makes them feel respected and helps maintain positive relationships.'),
(24,'Prioritizing your emotions and needs is important for building healthy self-esteem. Sacrificing yourself to meet others’ expectations is not sustainable in the long run.'),
(25,'Most people can understand rejection. Do not worry too much and speak honestly. This reduces misunderstandings and helps maintain positive relationships.'),
(26,'Saying no is a way to clarify your standards and boundaries. It is necessary to protect your values and principles. This helps communicate your boundaries to others.'),
(27,'Trying to understand each other’s perspectives in friendships reduces conflicts and fosters deeper bonds. This enhances empathy and respect for each other’s feelings.'),
(28,'Expressing emotions honestly helps others better understand your situation and feelings. This reduces misunderstandings, builds trust, and enables healthy communication.'),
(29,'Respecting different perspectives broadens your worldview. This helps understand differences, reduces conflicts, and leads to richer conversations.'),
(30,'Positive feedback boosts others’ self-esteem and encourages better behavior. This is important for maintaining healthy relationships and supporting mutual growth.'),
(31,'Forced kindness burdens both you and the other person. True kindness comes naturally, making relationships more comfortable and positive.'),
(32,'Calculated kindness often involves hidden intentions and is not genuine. It can damage trust. Kindness should come from a pure heart.'),
(33,'Recognizing that people have different thoughts and feelings helps you understand them better. This reduces unnecessary conflicts and enhances respect for their emotions.'),
(34,'Jumping to conclusions without fully understanding the other person’s situation can lead to incorrect judgments. Making an effort to understand them helps maintain healthy relationships.'),
(35,'Advice can sometimes be perceived as an attempt to change the other person, whereas empathy focuses on understanding and respecting their emotions. This builds deeper understanding and trust.'),
(36,'Relationships without mutual respect are harmful. It is important to maintain relationships based on respect and understanding.');

INSERT INTO aicharacter (characterId, aiName, description, difficultyLevel) VALUES
(1,'Miyeon','Miyeon is a very emotional type. She may feel disappointed or sad when her requests are denied. She is introverted but warm and considerate towards her friends, forming deep relationships and listening attentively to their concerns. It is important to empathize with and gently refuse Miyeon\'s requests.',1),
(2,'Sejin','Sejin is logical and responsible, making it easy for him to get along with people. However, he has a very calculative and pragmatic personality. He always weighs the pros and cons before doing anything and believes that those he has helped in the past must return the favor. Sejin tries to solve problems rationally and calmly, avoiding emotional influences. Because of this, he may sometimes appear cold, but he is a reliable person. People respect his practicality and rationality but sometimes feel distant from him. Sejin does not compromise on his principles and responds decisively when necessary.',2),
(3,'Hyuna','Hyuna persistently repeats her requests and tries to gain sympathy through honest emotional expressions. She achieves her goals through perseverance and persistence, but her personality can sometimes feel burdensome to others.',3),
(4,'Jinhyuk','Jinhyuk expresses emotions intensely and struggles with anger management. He has a very simple way of thinking and avoids complex situations or logical reasoning. This simplicity is reflected in his communication style, as he tends to make rude or aggressive requests.',4);


SET FOREIGN_KEY_CHECKS=1;
