-- Presentation fixtures V1: additive only; never run CreateDatabase.sql for this task.
-- Select the existing application database. Content only; history uses existing C# helpers.
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY BEGIN TRANSACTION;
IF OBJECT_ID('dbo.Payment','U') IS NULL THROW 51000, 'Select the existing upgraded LearningSystem database.', 1;
DECLARE @course int,@topic int,@activity int,@question int,@group int,@start int,@inspect int,@verify int,@best int,@acceptable int,@poor int;
DECLARE @Courses TABLE(Code nvarchar(10), CourseID int);
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'asha.teacher@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Asha Sharma',N'asha.teacher@example.test',N'PBKDF2$100000$XXLcJB7riHv0Pcg3NIrnCQ==$PJwyWVMAAO7vkwoMiJgNj+s83DdggOOlvWVH5BFydqo=',N'Teacher','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'asha.teacher@example.test' AND Role=N'Teacher' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'ravi.pending@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Ravi Thapa',N'ravi.pending@example.test',N'PBKDF2$100000$kKfWfV5lGEQ/tErPybwTnA==$3/pHl4rcb7EKq9Il/n4SSdr+6Lh+UTCllUG1Z4Q3DCE=',N'Teacher','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'ravi.pending@example.test' AND Role=N'Teacher' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'maya.teacher@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Maya Rai',N'maya.teacher@example.test',N'PBKDF2$100000$WkrkHrqlFevPXl9rww8RpQ==$ivexnPzY7MG3R4u0SlEF8x+FwwSSLKfiKEbYDVhbwhA=',N'Teacher','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'maya.teacher@example.test' AND Role=N'Teacher' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'daniel.teacher@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Daniel Tan',N'daniel.teacher@example.test',N'PBKDF2$100000$M9z9QATa06gZ5iKfPoK+0A==$kP9/puZXF2qgViHqhvslactqB/092rqGlKStUE8IuLA=',N'Teacher','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'daniel.teacher@example.test' AND Role=N'Teacher' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'anita.learner@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Anita Karki',N'anita.learner@example.test',N'PBKDF2$100000$SiWxWMV1ZUgMlb+q9SaeSg==$q4IrrS577ik2a7w2sE2dqX6211cO8eHAkirpF6VLkqA=',N'Learner','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'anita.learner@example.test' AND Role=N'Learner' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'ben.learner@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Ben Lee',N'ben.learner@example.test',N'PBKDF2$100000$lySm+pfxfLnhMBctRJTkgw==$dwmgwqe8E+O94BZEUcSWVkcdD4aUc79gCPnivOX6tSQ=',N'Learner','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'ben.learner@example.test' AND Role=N'Learner' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'chandra.learner@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Chandra Gurung',N'chandra.learner@example.test',N'PBKDF2$100000$aklfU80mq0lh1X/QCqO44Q==$pxWKxI9toWPIp0Epp6Gukcy7duHjCWrnijLiIZNKnF8=',N'Learner','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'chandra.learner@example.test' AND Role=N'Learner' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'dina.learner@example.test') INSERT dbo.[User](FullName,Email,PasswordHash,Role,Status) VALUES(N'Dina Wong',N'dina.learner@example.test',N'PBKDF2$100000$ZnY70uyRw7uCMvu3fKZL1w==$QwhhsSy/tS7hExdQmfxtdEP0jyqvX4p19IwEgcvonGg=',N'Learner','Active');
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Email=N'dina.learner@example.test' AND Role=N'Learner' AND Status='Active') THROW 51000, 'An existing presentation account has the wrong role/status; no account was overwritten.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.[User] WHERE Role='Admin' AND Status='Active') THROW 51000, 'An active Admin account is required; no new Admin privileges are created by this seed.', 1;
IF NOT EXISTS(SELECT 1 FROM dbo.Subject WHERE SubjectName=N'IT') INSERT dbo.Subject(SubjectName,Description) VALUES(N'IT',N'Foundation learning and practical skills.');
SET @course=(SELECT CourseID FROM dbo.Course WHERE Title=N'Web Development Fundamentals: Build Accessible Pages' AND TeacherID=(SELECT UserID FROM dbo.[User] WHERE Email=N'asha.teacher@example.test'));
IF @course IS NULL BEGIN
INSERT dbo.Course(TeacherID,SubjectID,Title,Description,CoverImagePath,Status,IsPaid,PriceNPR) VALUES((SELECT UserID FROM dbo.[User] WHERE Email=N'asha.teacher@example.test'),(SELECT SubjectID FROM dbo.Subject WHERE SubjectName=N'IT'),N'Web Development Fundamentals: Build Accessible Pages',N'A ten-topic foundation course with practical examples, reflection and guided activities. Learn to explain decisions and apply them to a realistic student project. Fictional presentation dataset [PRESENTATION-DEMO-V1:web].',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586011.jpg','Draft',0,0); SET @course=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'How the web delivers a page',1); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'How the web delivers a page - lesson','Text','Published',N'## How the web delivers a page

A browser asks a server for a resource using HTTP. The server returns a response containing HTML, an image or another resource. HTML describes meaning; CSS controls presentation; JavaScript adds behaviour. A useful first design decision is to make the important content readable before adding decoration.

### Worked example
Opening a school club website requests its HTML first, then its stylesheet and photographs. A missing photograph should not prevent a student from finding the meeting time.

### Try it yourself
Draw the request and response for a club homepage. Label browser, server, HTML, CSS and image.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',1,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,AltText,IsPreview,SortOrder) VALUES(@topic,N'Observe the course context: How the web delivers a page','Image','Published',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586011.jpg',N'Hands typing source code on a laptop',1,2);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Write a clear HTML document',2); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Write a clear HTML document - lesson','Text','Published',N'## Write a clear HTML document

Start with a doctype, a document language, a head and a body. Put the page title and character encoding in the head. Use one main heading to identify the page, followed by headings that describe sections in order. A heading communicates structure; it is not merely large text.

### Worked example
A study-group page can use h1 for the group name and h2 for Meeting times and How to join. A paragraph introduces the purpose without repeating the title.

### Try it yourself
Write a document outline for a study group and explain which information belongs in the head.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,TimeLimitMinutes,MaxAttempts) VALUES(@topic,'Quiz',N'Write a clear HTML document - knowledge check',N'Apply the course ideas. Four weighted questions; eight-minute limit and three attempts.','Draft',1,8,3); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Which element identifies the main content landmark?',1,1); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'main',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'span',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'b',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'small',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'What should a useful image alternative describe?',2,2); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'The information or purpose of the image',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'The original filename only',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Every pixel colour',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'The image file size',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Where must saved form input be validated?',2,3); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'On the server',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Only in JavaScript',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Only by the CSS',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Only in the browser placeholder',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Which CSS space is inside the border?',3,4); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Padding',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Margin',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Viewport',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'URL',0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Links, images and meaningful alternatives',3); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Links, images and meaningful alternatives - lesson','Text','Published',N'## Links, images and meaningful alternatives

Link text should describe its destination without depending on surrounding text. An informative image needs alt text that communicates its purpose. Decorative images can have empty alternatives when the same information already appears beside them. File names are not useful descriptions.

### Worked example
A link labelled Download timetable is clearer than Click here. A diagram showing three study stages needs an alternative describing the stages, rather than diagram.png.

### Try it yourself
Rewrite three vague link labels and write an alternative for an image that explains a learning process.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,YouTubeURL,IsPreview,SortOrder) VALUES(@topic,N'HTML guided tutorial by freeCodeCamp','YouTube','Published',N'https://www.youtube.com/watch?v=pQN-pnXPaVg',0,2);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Semantic sections and navigation',4); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Semantic sections and navigation - lesson','Text','Published',N'## Semantic sections and navigation

Header, nav, main, section, article and footer describe the purpose of content. A main landmark helps keyboard and screen-reader users skip repeated navigation. Use article for a self-contained item and section for related content with a heading. Semantic elements do not replace clear wording.

### Worked example
A course catalogue can contain a main section with an article for each course and a footer with support links. The navigation stays consistent on every page.

### Try it yourself
Sketch a course page and assign a semantic element to each major area. Explain where its main landmark begins.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,GameTemplate) VALUES(@topic,'Game',N'Match web concepts to their purpose',N'Practise the concepts with the game. Results are checked by the existing server scoring helper.','Draft',1,N'Matching'); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'HTML',N'Describes document meaning');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'CSS',N'Controls visual presentation');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'JavaScript',N'Adds interactive behaviour');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'Alt text',N'Communicates image purpose');
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'CSS selectors and readable typography',5); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'CSS selectors and readable typography - lesson','Text','Published',N'## CSS selectors and readable typography

A class selector lets several elements share a visual rule. Consistent line height and readable line length make a lesson easier to scan. Use sufficient contrast and avoid relying on colour alone for status. A small reusable set of styles is easier to maintain than different rules on every page.

### Worked example
The class lesson-card can define spacing and a border for several topics. A completed lesson also has the word Completed or a labelled tick, rather than just a green background.

### Try it yourself
Choose a body font size, line height and maximum content width. Explain how you would show an error without colour alone.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Understand the box model',6); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Understand the box model - lesson','Text','Published',N'## Understand the box model

An element consists of content, padding, border and margin. Padding creates space inside a box; margin separates it from neighbours. With border-box sizing, declared width includes padding and border. This makes responsive widths easier to reason about.

### Worked example
A card with width 300 pixels and 20-pixel padding can exceed its expected width unless its sizing rule includes padding. Reducing page width reveals layout assumptions quickly.

### Try it yourself
Draw a card and label its four layers. Predict how adding padding changes its width under each sizing rule.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Forms that explain what to enter',7); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Forms that explain what to enter - lesson','Text','Published',N'## Forms that explain what to enter

Associate every input with a visible label. Choose input types such as email and number to improve entry, but validate again on the server. A helpful error identifies the field and explains how to correct it. Keep values when unrelated validation fails.

### Worked example
A registration form labels Email address and explains an invalid address beside the field. It does not trust an input merely because the browser calls it an email field.

### Try it yourself
Design three fields for a club application and write one useful error message for each.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,IsClosed) VALUES(@topic,'Discussion',N'Forms that explain what to enter - exchange ideas',N'Share one practical example from this topic, explain your reasoning and reply respectfully to another learner. Do not include real personal data.','Published',1,0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Responsive layout for small screens',8); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Responsive layout for small screens - lesson','Text','Published',N'## Responsive layout for small screens

Start with a readable single-column layout. Add columns when the viewport has enough room, using flexible widths rather than fixed page widths. Images should fit their containers. Tables may need a labelled horizontal scroll region while the page itself remains within the viewport.

### Worked example
A course grid can show one card on a phone and three on a desktop. A long results table scrolls inside its own region without pushing the navigation off screen.

### Try it yourself
Describe what should change when your page narrows from desktop to phone. Identify one element that should stay the same.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Add a small JavaScript interaction',9); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Add a small JavaScript interaction - lesson','Text','Published',N'## Add a small JavaScript interaction

Attach behaviour to native buttons so keyboard and pointer users have the same action. Update visible text when state changes. Avoid using scripts for essential access control because people can modify browser code and form values. The server remains responsible for authorization and saved data.

### Worked example
A Show instructions button can toggle guidance and announce its state. A hidden course price is not trustworthy just because JavaScript filled it in.

### Try it yourself
Specify a toggle button using plain language: initial state, action, feedback and keyboard behaviour.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Review and publish a useful page',10); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Review and publish a useful page - lesson','Text','Published',N'## Review and publish a useful page

Check the page title, heading order, links, alternatives, labels, errors and keyboard focus before publication. Test a phone-sized viewport and make sure the user can return from terminal pages. Save a short list of improvements instead of hiding known limitations.

### Worked example
A club page is ready when meeting information is clear, links work, the join form explains errors and a phone user can read it without horizontal page scrolling.

### Try it yourself
Use the quick-reference PDF to review your document. Write three checks you passed and one improvement you would make next.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,IsPreview,SortOrder) VALUES(@topic,N'HTML and CSS quick reference','PDF','Published',N'~/Uploads/Documents/3ff3c1df-fc5a-51c9-847d-3a8e45a1cd4e.pdf',0,2);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder) VALUES(@topic,'SelfAssessment',N'Reflect on your web design confidence',N'Rate all statements from 1 to 5. Confidence is not a quiz score; compare attempts after more practice.','Draft',1); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can explain how the web delivers a page using an example.',1);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can apply semantic sections and navigation to a student project.',2);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can check my reasoning about understand the box model.',3);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can identify one limitation in my final project and plan an improvement.',4);
END;
IF NOT EXISTS(SELECT 1 FROM dbo.Course WHERE CourseID=@course AND Description LIKE '%[[]PRESENTATION-DEMO-V1:web]%') THROW 51000, 'A title/owner collision was found; unrelated content was not modified.', 1;
INSERT @Courses VALUES(N'web',@course);
IF NOT EXISTS(SELECT 1 FROM dbo.Subject WHERE SubjectName=N'IT') INSERT dbo.Subject(SubjectName,Description) VALUES(N'IT',N'Foundation learning and practical skills.');
SET @course=(SELECT CourseID FROM dbo.Course WHERE Title=N'Introduction to Databases: Design a Student Club System' AND TeacherID=(SELECT UserID FROM dbo.[User] WHERE Email=N'ravi.pending@example.test'));
IF @course IS NULL BEGIN
INSERT dbo.Course(TeacherID,SubjectID,Title,Description,CoverImagePath,Status,IsPaid,PriceNPR) VALUES((SELECT UserID FROM dbo.[User] WHERE Email=N'ravi.pending@example.test'),(SELECT SubjectID FROM dbo.Subject WHERE SubjectName=N'IT'),N'Introduction to Databases: Design a Student Club System',N'A ten-topic foundation course with practical examples, reflection and guided activities. Learn to explain decisions and apply them to a realistic student project. Fictional presentation dataset [PRESENTATION-DEMO-V1:db].',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586012.jpg','Draft',0,0); SET @course=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'From scattered records to structured data',1); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'From scattered records to structured data - lesson','Text','Published',N'## From scattered records to structured data

A database stores related facts in a structure that can be queried consistently. Begin by deciding what a record represents. Mixing several kinds of facts into one spreadsheet often creates duplicates and contradictory updates.

### Worked example
A club list repeats a student phone number beside every meeting attended. Updating only one copy leaves inconsistent details.

### Try it yourself
List the facts a school club needs and identify which facts describe students, clubs and memberships.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',1,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,AltText,IsPreview,SortOrder) VALUES(@topic,N'Observe the course context: From scattered records to structured data','Image','Published',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586012.jpg',N'Network cables connected to infrastructure used to access data',1,2);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Entities, attributes and primary keys',2); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Entities, attributes and primary keys - lesson','Text','Published',N'## Entities, attributes and primary keys

An entity is a kind of thing about which facts are stored. Attributes describe it. A primary key identifies one record uniquely and should remain stable when descriptive information changes. A display name is usually a poor key because names can repeat.

### Worked example
StudentID identifies a learner; FullName and YearLevel describe the learner. Two students can share a name without sharing their identifier.

### Try it yourself
Design a Student entity with four attributes and explain why its primary key is suitable.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,TimeLimitMinutes,MaxAttempts) VALUES(@topic,'Quiz',N'Entities, attributes and primary keys - knowledge check',N'Apply the course ideas. Four weighted questions; eight-minute limit and three attempts.','Draft',1,8,3); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Which key uniquely identifies a record?',1,1); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Primary key',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Display name',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Paragraph',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Colour',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'What resolves a many-to-many membership relationship?',2,2); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A joining table',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Repeating profiles in every row',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A public image',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A CSS class',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'What does a foreign key protect?',2,3); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A reference to an existing related row',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'The font size',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A web colour',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A video length',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'What makes related writes all-or-nothing?',3,4); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A transaction',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A screenshot',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A duplicate email',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A browser title',0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Relationships and foreign keys',3); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Relationships and foreign keys - lesson','Text','Published',N'## Relationships and foreign keys

A foreign key points to an existing record in another table. Relationships express how entities connect. One teacher may own many courses; a course has one owner. Referential integrity prevents a relationship from pointing to a record that does not exist.

### Worked example
Course.TeacherID references User.UserID. A course cannot safely claim ownership by an arbitrary number not present in User.

### Try it yourself
Draw a one-to-many relationship between Club and Meeting and identify the foreign key.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Resolve a many-to-many relationship',4); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Resolve a many-to-many relationship - lesson','Text','Published',N'## Resolve a many-to-many relationship

When each student can join many clubs and each club can contain many students, use a joining table. Its two foreign keys describe one membership. A composite unique key prevents the same student from joining the same club twice accidentally.

### Worked example
Membership(StudentID, ClubID, JoinedDate) records the link and its date without copying a student profile into the club.

### Try it yourself
Write three sample membership rows and identify which proposed duplicate should be rejected.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,GameTemplate) VALUES(@topic,'Game',N'Unscramble database vocabulary',N'Practise the concepts with the game. Results are checked by the existing server scoring helper.','Draft',1,N'Scramble'); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'TABLE',N'A collection of related rows');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'COLUMN',N'An attribute stored for each row');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'QUERY',N'A request to read selected data');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'JOIN',N'Combines records through related keys');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'KEY',N'Identifies or relates database records');
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Choose appropriate data types',5); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Choose appropriate data types - lesson','Text','Published',N'## Choose appropriate data types

Use integers for whole-number identifiers, decimals for money, dates for timestamps and Unicode text for names. Choose a size based on a meaningful requirement. A value being optional should be represented deliberately rather than by a confusing magic number.

### Worked example
A price of NPR 499.00 fits a fixed-point decimal. A missing optional phone can be NULL, rather than the text none typed into a numeric field.

### Try it yourself
Choose types for a club name, subscription amount, meeting time and optional room note.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Read data with SELECT and WHERE',6); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Read data with SELECT and WHERE - lesson','Text','Published',N'## Read data with SELECT and WHERE

SELECT chooses columns; WHERE restricts rows. Ask for only the information needed for the task. A search query must use parameters so user input is treated as data. Filtering public results is also an access rule, not just a visual preference.

### Worked example
A public catalogue selects published course titles and excludes drafts even if the browser requests a draft filter.

### Try it yourself
Describe a query that lists active members of one club. Separate the required columns from the filtering conditions.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Combine related tables with JOIN',7); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Combine related tables with JOIN - lesson','Text','Published',N'## Combine related tables with JOIN

A JOIN combines rows through their relationship keys. An inner join returns matching records; a left join also retains rows from the left side without matches. Joining through descriptive names can produce ambiguous or duplicated results.

### Worked example
Join Membership to Student on StudentID to show member names. Left join Club to Membership to include clubs with zero members.

### Try it yourself
Explain which join would show every club, including a newly created club without members.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,IsClosed) VALUES(@topic,'Discussion',N'Combine related tables with JOIN - exchange ideas',N'Share one practical example from this topic, explain your reasoning and reply respectfully to another learner. Do not include real personal data.','Published',1,0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Use constraints to prevent bad data',8); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Use constraints to prevent bad data - lesson','Text','Published',N'## Use constraints to prevent bad data

Unique, foreign-key and CHECK constraints protect stored data even when a page has a validation bug. They complement server checks. Constraints should represent approved rules and should not depend on assumptions that the application never promised.

### Worked example
A review rating CHECK accepts integers from 1 through 5. A unique learner/course pair prevents duplicate reviews.

### Try it yourself
Propose three constraints for the club system and give one rejected example for each.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Keep related changes atomic',9); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Keep related changes atomic - lesson','Text','Published',N'## Keep related changes atomic

A transaction groups related writes so they either commit together or do not take effect. Delete children before parents where cascading is not approved. Do not announce success until the complete operation has committed.

### Worked example
Deleting a discussion post and its replies in one transaction prevents orphan replies. A payment and enrolment must agree about successful purchase state.

### Try it yourself
Describe the steps for transferring a membership record safely and identify which operations belong in one transaction.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Review a complete club database',10); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Review a complete club database - lesson','Text','Published',N'## Review a complete club database

Check every entity, key, relationship and validation rule against actual user tasks. Write sample queries for common questions. Back up important data before changing it; a presentation seed is not a reason to destroy useful records.

### Worked example
A complete club model can answer who belongs to a club, when they joined and which clubs currently have no members.

### Try it yourself
Use the revision planner to schedule practice. Explain your model to a partner using one membership example.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,IsPreview,SortOrder) VALUES(@topic,N'Plan your database revision','PDF','Published',N'~/Uploads/Documents/e28a1c83-920c-5aa0-8c4f-d05bc0cf807e.pdf',0,2);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder) VALUES(@topic,'SelfAssessment',N'Reflect on your database confidence',N'Rate all statements from 1 to 5. Confidence is not a quiz score; compare attempts after more practice.','Draft',1); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can explain from scattered records to structured data using an example.',1);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can apply resolve a many-to-many relationship to a student project.',2);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can check my reasoning about read data with select and where.',3);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can identify one limitation in my final project and plan an improvement.',4);
END;
IF NOT EXISTS(SELECT 1 FROM dbo.Course WHERE CourseID=@course AND Description LIKE '%[[]PRESENTATION-DEMO-V1:db]%') THROW 51000, 'A title/owner collision was found; unrelated content was not modified.', 1;
INSERT @Courses VALUES(N'db',@course);
IF NOT EXISTS(SELECT 1 FROM dbo.Subject WHERE SubjectName=N'IT') INSERT dbo.Subject(SubjectName,Description) VALUES(N'IT',N'Foundation learning and practical skills.');
SET @course=(SELECT CourseID FROM dbo.Course WHERE Title=N'Digital Safety and Cyber Awareness: Make Safer Decisions' AND TeacherID=(SELECT UserID FROM dbo.[User] WHERE Email=N'maya.teacher@example.test'));
IF @course IS NULL BEGIN
INSERT dbo.Course(TeacherID,SubjectID,Title,Description,CoverImagePath,Status,IsPaid,PriceNPR) VALUES((SELECT UserID FROM dbo.[User] WHERE Email=N'maya.teacher@example.test'),(SELECT SubjectID FROM dbo.Subject WHERE SubjectName=N'IT'),N'Digital Safety and Cyber Awareness: Make Safer Decisions',N'A ten-topic foundation course with practical examples, reflection and guided activities. Learn to explain decisions and apply them to a realistic student project. Fictional presentation dataset [PRESENTATION-DEMO-V1:safe].',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586013.jpg','Draft',1,499); SET @course=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Recognize what you need to protect',1); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Recognize what you need to protect - lesson','Text','Published',N'## Recognize what you need to protect

Personal information, account access and study work are valuable assets. Security starts by identifying what could be lost and who should have access. An ordinary-looking message can still request information that deserves careful handling.

### Worked example
A school login protects assignments and personal records. Sharing a password gives another person access beyond one intended document.

### Try it yourself
List three digital assets you use for study and one realistic risk to each.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',1,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,AltText,IsPreview,SortOrder) VALUES(@topic,N'Observe the course context: Recognize what you need to protect','Image','Published',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586013.jpg',N'A person working on a laptop in a digital workspace',1,2);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Build stronger account habits',2); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Build stronger account habits - lesson','Text','Published',N'## Build stronger account habits

Use a unique long password for each important account and enable a second factor where supported. A password manager can reduce reuse. Do not share verification codes with someone who contacts you, even when the caller claims to be support.

### Worked example
A reused password exposes several accounts when one service leaks it. A second factor helps, but approving an unexpected login request can still grant access.

### Try it yourself
Describe how you would respond to an unexpected verification-code request.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,TimeLimitMinutes,MaxAttempts) VALUES(@topic,'Quiz',N'Build stronger account habits - knowledge check',N'Apply the course ideas. Four weighted questions; eight-minute limit and three attempts.','Draft',1,8,3); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'What should you do with an unexpected verification code request?',1,1); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Do not share it; verify through a known route',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Read the code to the caller',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Post it in a group',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Send your password too',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Which action is safer for an urgent school login link?',2,2); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Open the official school site independently',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Click the shortened link',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Reply with credentials',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Disable certificate checks',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Which is useful on a shared computer?',2,3); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Log out and lock or end the session',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Close only one tab',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Save every password',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Leave the account open',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'What should you do after suspected credential disclosure?',3,4); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Use official recovery and report promptly',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Pay an unknown recovery service',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Ignore it',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Forward private details publicly',0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Spot phishing without guessing',3); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Spot phishing without guessing - lesson','Text','Published',N'## Spot phishing without guessing

Look for unexpected requests, pressure and a destination that differs from the claimed organization. Sender display names and logos are easy to copy. Verify through a known route instead of clicking the message link to investigate it.

### Worked example
An urgent fee message asks for a login on a shortened link. Opening the official school site independently gives a safer way to check the claim.

### Try it yourself
Write two warning signs and one verification step for an urgent scholarship message.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Separate useful access from excessive access',4); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Separate useful access from excessive access - lesson','Text','Published',N'## Separate useful access from excessive access

Give an application only the permissions needed for its purpose. Review why it asks for contacts, location or files. A privacy policy can explain handling, but a long document alone is not proof that an unnecessary permission is safe.

### Worked example
A calculator does not need access to all photographs. A study app may need a chosen document without needing every file in the account.

### Try it yourself
Choose one permission you would deny to a simple study timer and explain why.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,GameTemplate) VALUES(@topic,'Game',N'Remember safer account habits',N'Practise the concepts with the game. Results are checked by the existing server scoring helper.','Draft',1,N'Memory'); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'Unique password',N'Avoid reusing an account secret');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'Second factor',N'Add another proof at sign-in');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'Official route',N'Verify through a known destination');
INSERT dbo.GameItem(ActivityID,ItemText,MatchText) VALUES(@activity,N'Log out',N'End access on a shared device');
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Use devices and networks thoughtfully',5); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Use devices and networks thoughtfully - lesson','Text','Published',N'## Use devices and networks thoughtfully

Keep devices updated, lock the screen and avoid leaving accounts open on shared computers. A public network does not make every site unsafe, but sensitive work deserves careful attention to the destination and connection. Never bypass a certificate warning casually.

### Worked example
A library computer remains signed in after a session ends unless the learner logs out. Closing one tab may not end the account session.

### Try it yourself
Create a three-step checklist for leaving a shared computer.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Choose a response to a suspicious message',6); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Choose a response to a suspicious message - lesson','Text','Published',N'## Choose a response to a suspicious message

A useful response balances caution, verification and timely reporting. Deleting evidence immediately can make investigation harder. Replying to a suspicious sender may confirm that the account is active. Use a trusted contact route instead.

### Worked example
A learner receives an urgent request to reset a school account. The best path is to inspect the request safely, verify with the school and report suspicious details.

### Try it yourself
Play the branching scenario below. Try a cautious path, a poor path and a path that returns to re-check evidence.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder) VALUES(@topic,'Scenario',N'The urgent scholarship message',N'A fictional message asks you to confirm a scholarship within ten minutes. Follow choices, verify evidence and reach one of three outcomes.','Draft',1); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback) VALUES(@activity,N'An urgent message claims your scholarship will be withdrawn unless you confirm your school login now. What will you do?',0,NULL,NULL); SET @start=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback) VALUES(@activity,N'You notice a shortened link and an unfamiliar sender address. The school logo looks convincing, but you have not verified the request.',0,NULL,NULL); SET @inspect=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback) VALUES(@activity,N'The official school portal has no such notice. A staff member says the message should be reported. Choose your response.',0,NULL,NULL); SET @verify=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback) VALUES(@activity,N'You use the official contact route, report the suspicious message and keep your credentials private.',1,N'Best',N'You verified independently and reported useful evidence without sharing credentials. This protects your account and helps others.'); SET @best=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback) VALUES(@activity,N'You decide not to click and put the message aside, but you do not report it or ask the school to investigate.',1,N'Acceptable',N'You avoided sharing credentials. Reporting through an official route would also help the school investigate and warn others.'); SET @acceptable=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback) VALUES(@activity,N'You follow the message link and enter your school password into the unverified page.',1,N'Poor',N'The destination was unverified and you exposed a credential. Use the official recovery route promptly and report the incident.'); SET @poor=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@start,@inspect,N'Inspect the request without opening the link');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@start,@poor,N'Follow the link and enter my password');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@start,@acceptable,N'Ignore the message without reporting');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@inspect,@verify,N'Open the official portal and contact the school');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@inspect,@start,N'Return to the message and reconsider the evidence');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@inspect,@poor,N'Trust the copied logo and enter my password');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@verify,@best,N'Report the message through the official route');
INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@verify,@acceptable,N'Do nothing further');
UPDATE dbo.Activity SET StartStepID=@start WHERE ActivityID=@activity;
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Share files with the right audience',7); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Share files with the right audience - lesson','Text','Published',N'## Share files with the right audience

Before sharing, identify the audience and the minimum access needed. View access differs from edit access. Public links can travel beyond the intended group. Remove sensitive details that are not needed for the task.

### Worked example
A group revision sheet can be shared with members as editors while a public announcement remains read-only. A class contact list should not be posted publicly.

### Try it yourself
Compare a public link with a named-person invitation for a class contact sheet.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,IsClosed) VALUES(@topic,'Discussion',N'Share files with the right audience - exchange ideas',N'Share one practical example from this topic, explain your reasoning and reply respectfully to another learner. Do not include real personal data.','Published',1,0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Recover from mistakes promptly',8); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Recover from mistakes promptly - lesson','Text','Published',N'## Recover from mistakes promptly

If you reveal a password or approve a suspicious login, act quickly using official account recovery routes. Change affected credentials, review sessions and report the incident. Avoid paying an unknown service promising instant recovery.

### Worked example
After entering a password on a false page, a learner uses the official site to change it and signs out other sessions. They report the original message.

### Try it yourself
Write the first three actions you would take after entering a password on a suspected phishing page.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Check claims before spreading them',9); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Check claims before spreading them - lesson','Text','Published',N'## Check claims before spreading them

Digital safety includes the quality of information you share. Examine the original source, date and evidence. A dramatic screenshot can omit context. Avoid forwarding private information merely to warn others about a possible scam.

### Worked example
A message claims every school account will close today but provides no official notice. Checking the official announcement channel prevents unnecessary panic.

### Try it yourself
Describe how you would verify a security warning before posting it to a class group.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Create a sustainable safety routine',10); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Create a sustainable safety routine - lesson','Text','Published',N'## Create a sustainable safety routine

Security improves through small repeated habits: updates, unique credentials, careful sharing and calm verification. Build a routine that fits your actual study schedule. Confidence should reflect what you can explain and practise, not just recognition of a term.

### Worked example
A weekly review checks device updates and shared links, while a suspicious-message habit is used whenever a new request arrives.

### Try it yourself
Use the planner to schedule three safety habits. Explain one decision you changed after playing the scenario.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,IsPreview,SortOrder) VALUES(@topic,N'Schedule your cyber-safety practice','PDF','Published',N'~/Uploads/Documents/e28a1c83-920c-5aa0-8c4f-d05bc0cf807e.pdf',0,2);
END;
IF NOT EXISTS(SELECT 1 FROM dbo.Course WHERE CourseID=@course AND Description LIKE '%[[]PRESENTATION-DEMO-V1:safe]%') THROW 51000, 'A title/owner collision was found; unrelated content was not modified.', 1;
INSERT @Courses VALUES(N'safe',@course);
IF NOT EXISTS(SELECT 1 FROM dbo.Subject WHERE SubjectName=N'Business') INSERT dbo.Subject(SubjectName,Description) VALUES(N'Business',N'Foundation learning and practical skills.');
SET @course=(SELECT CourseID FROM dbo.Course WHERE Title=N'Entrepreneurship and Business Basics: Plan a Small Venture' AND TeacherID=(SELECT UserID FROM dbo.[User] WHERE Email=N'daniel.teacher@example.test'));
IF @course IS NULL BEGIN
INSERT dbo.Course(TeacherID,SubjectID,Title,Description,CoverImagePath,Status,IsPaid,PriceNPR) VALUES((SELECT UserID FROM dbo.[User] WHERE Email=N'daniel.teacher@example.test'),(SELECT SubjectID FROM dbo.Subject WHERE SubjectName=N'Business'),N'Entrepreneurship and Business Basics: Plan a Small Venture',N'A ten-topic foundation course with practical examples, reflection and guided activities. Learn to explain decisions and apply them to a realistic student project. Fictional presentation dataset [PRESENTATION-DEMO-V1:biz].',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586014.jpg','Draft',1,999); SET @course=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Start with a customer problem',1); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Start with a customer problem - lesson','Text','Published',N'## Start with a customer problem

A business idea should solve a problem for a specific group. Begin with what people need rather than with a product you simply enjoy making. Describe the problem clearly enough that someone else can test whether it exists.

### Worked example
Students arriving early may need an affordable breakfast near campus. The idea is stronger when the customer and the inconvenience are specific.

### Try it yourself
Write a one-sentence problem statement for a small campus venture.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',1,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,AltText,IsPreview,SortOrder) VALUES(@topic,N'Observe the course context: Start with a customer problem','Image','Published',N'~/Uploads/Images/b28d45b0-2d45-4d51-9974-a196a3586014.jpg',N'A team discussing ideas around a business meeting table',1,2);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Research before assuming demand',2); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Research before assuming demand - lesson','Text','Published',N'## Research before assuming demand

Ask potential customers about their current behaviour and difficulties. Questions that suggest the desired answer produce weak evidence. Combine a few interviews with observations and a small trial rather than claiming everyone will buy.

### Worked example
Ask what students currently eat and spend in the morning instead of asking whether they love your proposed snack.

### Try it yourself
Write three neutral customer interview questions and explain what each could teach you.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,TimeLimitMinutes,MaxAttempts) VALUES(@topic,'Quiz',N'Research before assuming demand - knowledge check',N'Apply the course ideas. Four weighted questions; eight-minute limit and three attempts.','Draft',1,8,3); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Who should an idea solve a problem for?',1,1); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'A specific customer group',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Everyone without research',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Only the designer',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'An unnamed imaginary audience',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'Which is usually a variable cost for a snack seller?',2,2); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Ingredients per snack',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Monthly stall rent',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'Annual license',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'One-time sign design',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'NPR 100 price minus NPR 60 variable cost gives what contribution?',2,3); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'NPR 40',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'NPR 160',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'NPR 60',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'NPR 0',0);
INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,N'NPR 2000 fixed cost and NPR 40 contribution require how many units?',3,4); SET @question=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'50',1);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'20',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'40',0);
INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,N'2000',0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Explain your value proposition',3); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Explain your value proposition - lesson','Text','Published',N'## Explain your value proposition

A value proposition describes the benefit, audience and reason to choose the offer. It should be specific enough to compare with alternatives. Avoid claiming highest quality or lowest price without evidence.

### Worked example
A pre-ordered breakfast box saves queue time for early commuters. Its benefit is convenience, not merely that it contains food.

### Try it yourself
Compare your venture with an existing alternative and state one credible difference.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Distinguish fixed and variable costs',4); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Distinguish fixed and variable costs - lesson','Text','Published',N'## Distinguish fixed and variable costs

A fixed cost does not change directly with each item sold within the planned operating range. A variable cost changes with units produced or sold. This distinction helps explain how sales affect profit.

### Worked example
A monthly stall fee is fixed; ingredients and a takeaway box for each meal are variable. More sales increase both revenue and variable costs.

### Try it yourself
Sort the cost cards below and explain one classification that depends on the operating arrangement.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,GameTemplate) VALUES(@topic,'Game',N'Sort fixed and variable business costs',N'Practise the concepts with the game. Results are checked by the existing server scoring helper.','Draft',1,N'Sort'); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.GameGroup(ActivityID,GroupName) VALUES(@activity,N'Fixed costs');
INSERT dbo.GameGroup(ActivityID,GroupName) VALUES(@activity,N'Variable costs');
SET @group=(SELECT GroupID FROM dbo.GameGroup WHERE ActivityID=@activity AND GroupName=N'Fixed costs'); INSERT dbo.GameItem(ActivityID,GroupID,ItemText) VALUES(@activity,@group,N'Monthly stall rent');
SET @group=(SELECT GroupID FROM dbo.GameGroup WHERE ActivityID=@activity AND GroupName=N'Fixed costs'); INSERT dbo.GameItem(ActivityID,GroupID,ItemText) VALUES(@activity,@group,N'Annual trading license');
SET @group=(SELECT GroupID FROM dbo.GameGroup WHERE ActivityID=@activity AND GroupName=N'Fixed costs'); INSERT dbo.GameItem(ActivityID,GroupID,ItemText) VALUES(@activity,@group,N'Insurance for the month');
SET @group=(SELECT GroupID FROM dbo.GameGroup WHERE ActivityID=@activity AND GroupName=N'Variable costs'); INSERT dbo.GameItem(ActivityID,GroupID,ItemText) VALUES(@activity,@group,N'Ingredients per meal');
SET @group=(SELECT GroupID FROM dbo.GameGroup WHERE ActivityID=@activity AND GroupName=N'Variable costs'); INSERT dbo.GameItem(ActivityID,GroupID,ItemText) VALUES(@activity,@group,N'Takeaway box per meal');
SET @group=(SELECT GroupID FROM dbo.GameGroup WHERE ActivityID=@activity AND GroupName=N'Variable costs'); INSERT dbo.GameItem(ActivityID,GroupID,ItemText) VALUES(@activity,@group,N'Delivery charge per order');
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Choose a price with a reason',5); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Choose a price with a reason - lesson','Text','Published',N'## Choose a price with a reason

Price should cover costs and reflect what customers value and can pay. Revenue is price times quantity, while profit also accounts for expenses. Discounts reduce contribution per unit unless they create enough extra sales to compensate.

### Worked example
A snack sells for NPR 100 and has NPR 60 variable cost, leaving NPR 40 toward fixed costs and profit.

### Try it yourself
Calculate contribution for a product priced at NPR 150 with NPR 90 variable cost.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Calculate a simple break-even point',6); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Calculate a simple break-even point - lesson','Text','Published',N'## Calculate a simple break-even point

Break-even units equal fixed costs divided by contribution per unit when contribution is positive. Round up when selling whole items. The estimate depends on the costs and price remaining close to the assumptions.

### Worked example
With NPR 2000 fixed costs and NPR 40 contribution, the venture needs 50 units to cover costs. At 49 units it has not yet broken even.

### Try it yourself
Calculate break-even units for NPR 3000 fixed cost and NPR 50 contribution. State one assumption.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Plan cash as well as profit',7); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Plan cash as well as profit - lesson','Text','Published',N'## Plan cash as well as profit

Cash flow tracks when money enters and leaves. A profitable order can still create a cash shortage if supplies must be bought long before payment arrives. Keep a simple budget and separate personal and venture money where practical.

### Worked example
Buying ingredients on Monday for customers who pay on Friday creates a temporary cash need. The budget worksheet helps identify it.

### Try it yourself
Use the worksheet to plan one week of cash receipts and payments.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder,IsClosed) VALUES(@topic,'Discussion',N'Plan cash as well as profit - exchange ideas',N'Share one practical example from this topic, explain your reasoning and reply respectfully to another learner. Do not include real personal data.','Published',1,0);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Reach customers honestly',8); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Reach customers honestly - lesson','Text','Published',N'## Reach customers honestly

Choose a channel that the intended audience actually uses. Explain the offer and its price clearly. Advertising should not invent reviews, hide conditions or imply endorsements from people in a stock photograph.

### Worked example
A poster near the commuter entrance may reach breakfast customers better than a broad online campaign. A clear collection time reduces confusion.

### Try it yourself
Draft a short advertisement with price, benefit, collection details and no unsupported claims.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Test, learn and manage risks',9); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Test, learn and manage risks - lesson','Text','Published',N'## Test, learn and manage risks

A small trial reveals weaknesses before a large commitment. Define what success means, record feedback and change one major assumption at a time. Identify risks such as spoilage, unreliable suppliers and unexpectedly low demand.

### Worked example
A three-day pre-order trial reduces waste and measures repeat interest. Unsold stock becomes evidence for changing quantity or menu.

### Try it yourself
Design a low-cost trial and identify the evidence that would make you change the plan.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Topic(CourseID,Title,SortOrder) VALUES(@course,N'Present a practical venture plan',10); SET @topic=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,TextContent,IsPreview,SortOrder) VALUES(@topic,N'Present a practical venture plan - lesson','Text','Published',N'## Present a practical venture plan

A concise plan connects customer problem, offer, costs, pricing, operations, risks and evidence. Explain uncertainty rather than disguising estimates as facts. The goal is a decision that others can understand and challenge constructively.

### Worked example
A breakfast-box pitch can show interview findings, a weekly budget and a break-even calculation before requesting a larger trial.

### Try it yourself
Prepare a two-minute pitch. Include one calculation, one customer insight and one remaining uncertainty.

### Reflection
Explain your reasoning to a partner. Compare your example with the lesson and note one assumption that could change your answer.',0,1);
INSERT dbo.Material(TopicID,Title,MaterialType,Status,FilePath,IsPreview,SortOrder) VALUES(@topic,N'Budget worksheet for your venture','PDF','Published',N'~/Uploads/Documents/47bd851f-4cc1-5dd4-9b0c-cc48bb2d4dd4.pdf',0,2);
INSERT dbo.Activity(TopicID,ActivityType,Title,Description,Status,SortOrder) VALUES(@topic,'SelfAssessment',N'Reflect on your venture planning confidence',N'Rate all statements from 1 to 5. Confidence is not a quiz score; compare attempts after more practice.','Draft',1); SET @activity=CAST(SCOPE_IDENTITY() AS int);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can explain start with a customer problem using an example.',1);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can apply distinguish fixed and variable costs to a student project.',2);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can check my reasoning about calculate a simple break-even point.',3);
INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,N'I can identify one limitation in my final project and plan an improvement.',4);
END;
IF NOT EXISTS(SELECT 1 FROM dbo.Course WHERE CourseID=@course AND Description LIKE '%[[]PRESENTATION-DEMO-V1:biz]%') THROW 51000, 'A title/owner collision was found; unrelated content was not modified.', 1;
INSERT @Courses VALUES(N'biz',@course);
COMMIT TRANSACTION;
END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK TRANSACTION; THROW; END CATCH;
SELECT d.Code,c.CourseID,c.Title,c.Status,c.IsPaid,c.PriceNPR,u.Email AS TeacherEmail FROM @Courses d JOIN dbo.Course c ON c.CourseID=d.CourseID JOIN dbo.[User] u ON u.UserID=c.TeacherID ORDER BY d.Code;
