-- Extra learning games: one new game for each topic, using a game type the topic did not have.
-- Additive and safe to re-run: a game is only added when its topic does not already have a game with the same title.
SET NOCOUNT ON;
DECLARE @topic INT, @activity INT, @group INT;

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'HTML and CSS: Build Your First Web Page' AND t.Title = N'How a web page is built');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Tag pairs memory')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Tag pairs memory', N'Flip cards to pair each HTML tag with the job it does.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Memory');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'<h1>', N'Main heading', NULL), (@activity, N'<p>', N'Paragraph of text', NULL), (@activity, N'<a>', N'Link to another page', NULL), (@activity, N'<img>', N'Picture with alt text', NULL), (@activity, N'<ul>', N'Bulleted list', NULL), (@activity, N'<li>', N'One list item', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'HTML and CSS: Build Your First Web Page' AND t.Title = N'Styling with CSS');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Box model from the inside out')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Box model from the inside out', N'Put the layers of the CSS box model in order, starting from the middle.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sequence');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Content: the text or image itself', N'1', NULL), (@activity, N'Padding: space inside the border', N'2', NULL), (@activity, N'Border: the line around the padding', N'3', NULL), (@activity, N'Margin: space outside the border', N'4', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'HTML and CSS: Build Your First Web Page' AND t.Title = N'Publishing a page that works for everyone');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Accessibility true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Accessibility true or false', N'Decide quickly whether each statement about accessible pages is true.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'Every meaningful image needs alt text that describes it.', NULL), (@activity, N'False', N'Colour alone is enough to show that a form field has an error.', NULL), (@activity, N'True', N'Headings should go in order, without skipping from h1 to h4.', NULL), (@activity, N'True', N'A page should still be usable with a keyboard and no mouse.', NULL), (@activity, N'False', N'Link text such as ''click here'' tells screen reader users where a link goes.', NULL), (@activity, N'True', N'A viewport meta tag helps a page fit small phone screens.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'JavaScript Basics for the Browser' AND t.Title = N'Values, variables and decisions');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Match the JavaScript value')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Match the JavaScript value', N'Pair each value with its JavaScript data type.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'42', N'number', NULL), (@activity, N'"hello"', N'string', NULL), (@activity, N'true', N'boolean', NULL), (@activity, N'undefined', N'a variable with no value yet', NULL), (@activity, N'[1, 2, 3]', N'array', NULL), (@activity, N'{ name: "Sam" }', N'object', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'JavaScript Basics for the Browser' AND t.Title = N'Loops and functions');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Complete the loop')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Complete the loop', N'Type the missing keyword in each line of JavaScript.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'FillBlank');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'for', N'___ (let i = 0; i < 5; i++) { console.log(i); }', NULL), (@activity, N'function', N'___ greet(name) { return "Hi " + name; }', NULL), (@activity, N'return', N'function double(n) { ___ n * 2; }', NULL), (@activity, N'while', N'let n = 3; ___ (n > 0) { n--; }', NULL), (@activity, N'break', N'Inside a loop, ___ stops the loop straight away.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'JavaScript Basics for the Browser' AND t.Title = N'Responding to the user');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Event or method?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Event or method?', N'Sort each word into browser events or DOM methods.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Events'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'click', NULL, @group), (@activity, N'keydown', NULL, @group), (@activity, N'submit', NULL, @group), (@activity, N'input', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Methods'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'addEventListener', NULL, @group), (@activity, N'querySelector', NULL, @group), (@activity, N'preventDefault', NULL, @group), (@activity, N'createElement', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Digital Safety Essentials' AND t.Title = N'Protecting your accounts');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Strong or weak?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Strong or weak?', N'Sort each habit into strong or weak account security.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Strong habits'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'A long passphrase', NULL, @group), (@activity, N'Two-step verification', NULL, @group), (@activity, N'A password manager', NULL, @group), (@activity, N'A different password per site', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Weak habits'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Your pet''s name', NULL, @group), (@activity, N'One password everywhere', NULL, @group), (@activity, N'Sharing a login with friends', NULL, @group), (@activity, N'Writing it on your laptop', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Digital Safety Essentials' AND t.Title = N'Recognising suspicious messages');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Phishing true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Phishing true or false', N'Is each statement about suspicious messages true or false?', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'Urgent deadlines are a common pressure tactic in phishing.', NULL), (@activity, N'False', N'A message is safe if it shows your bank''s logo.', NULL), (@activity, N'True', N'You can check a link''s real address before you open it.', NULL), (@activity, N'True', N'It is safer to visit a site by typing its address yourself.', NULL), (@activity, N'False', N'Your college IT team will ask for your password by email.', NULL), (@activity, N'True', N'Unexpected attachments can contain malware.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Digital Safety Essentials' AND t.Title = N'Your digital footprint');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Digital footprint flashcards')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Digital footprint flashcards', N'Flip each card to check the meaning, then rate how well you knew it.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Flashcards');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Digital footprint', N'The trail of data you leave online, from posts to searches.', NULL), (@activity, N'Privacy setting', N'A control that limits who can see your profile or posts.', NULL), (@activity, N'Cookie', N'A small file a website stores to remember you.', NULL), (@activity, N'Metadata', N'Hidden details in a file, such as when and where a photo was taken.', NULL), (@activity, N'Location sharing', N'An app setting that reveals where you are.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Starting a Small Business' AND t.Title = N'Customers and value');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Business words match')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Business words match', N'Match each business term to what it means.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Target market', N'The group of customers you aim to sell to', NULL), (@activity, N'Value proposition', N'Why a customer should choose you', NULL), (@activity, N'Competitor', N'Another business selling to the same customers', NULL), (@activity, N'Unique selling point', N'What makes your product different', NULL), (@activity, N'Market research', N'Finding out what customers need', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Starting a Small Business' AND t.Title = N'Costs and break-even');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Break-even blanks')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Break-even blanks', N'Type the missing word in each sentence about costs.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'FillBlank');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'fixed', N'Rent stays the same each month, so it is a ___ cost.', NULL), (@activity, N'variable', N'Ingredients rise with every unit made, so they are a ___ cost.', NULL), (@activity, N'profit', N'Revenue minus total costs is ___.', NULL), (@activity, N'break', N'At the ___-even point, revenue equals total costs.', NULL), (@activity, N'margin', N'Price minus variable cost per unit is the contribution ___.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Cells and Scientific Enquiry' AND t.Title = N'Inside a cell');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Cell facts true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Cell facts true or false', N'Is each statement about cells true or false?', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'The nucleus holds the cell''s genetic material.', NULL), (@activity, N'False', N'Animal cells have a cell wall.', NULL), (@activity, N'True', N'Mitochondria release energy in respiration.', NULL), (@activity, N'True', N'Chloroplasts are found in plant cells, not animal cells.', NULL), (@activity, N'False', N'The cell membrane lets every substance pass freely.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Cells and Scientific Enquiry' AND t.Title = N'Planning a fair test');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Plan a fair test')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Plan a fair test', N'Put the stages of a scientific investigation in order.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sequence');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Ask a question you can test', N'1', NULL), (@activity, N'Write a prediction', N'2', NULL), (@activity, N'Choose the variable to change and keep the others the same', N'3', NULL), (@activity, N'Carry out the test and record results', N'4', NULL), (@activity, N'Draw a conclusion from the evidence', N'5', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Chemistry of Everyday Reactions' AND t.Title = N'Signs of a chemical reaction');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Reaction signs flashcards')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Reaction signs flashcards', N'Flip each card to see an example, then rate yourself.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Flashcards');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Gas given off', N'Bubbles when vinegar meets baking soda', NULL), (@activity, N'Colour change', N'Iron turning orange-brown as it rusts', NULL), (@activity, N'Temperature change', N'A hand warmer heating up when opened', NULL), (@activity, N'New solid forms', N'A cloudy precipitate when two solutions mix', NULL), (@activity, N'Light given off', N'A glow stick shining after it is bent', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Chemistry of Everyday Reactions' AND t.Title = N'Balancing equations');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Formula match')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Formula match', N'Match each chemical formula to its everyday name.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'H2O', N'Water', NULL), (@activity, N'CO2', N'Carbon dioxide', NULL), (@activity, N'NaCl', N'Table salt', NULL), (@activity, N'O2', N'Oxygen gas', NULL), (@activity, N'CH4', N'Methane', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Chemistry of Everyday Reactions' AND t.Title = N'Acids and bases');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Acid or alkali?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Acid or alkali?', N'Sort each household substance into acids or alkalis.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Acids'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Lemon juice', NULL, @group), (@activity, N'Vinegar', NULL, @group), (@activity, N'Cola', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Alkalis'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Soap', NULL, @group), (@activity, N'Baking soda solution', NULL, @group), (@activity, N'Oven cleaner', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Algebra Foundations' AND t.Title = N'Expressions');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Algebra true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Algebra true or false', N'Decide whether each algebra statement is true.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'3x + 2x simplifies to 5x.', NULL), (@activity, N'False', N'x + x is the same as x squared.', NULL), (@activity, N'True', N'In 4y, the number 4 is the coefficient.', NULL), (@activity, N'False', N'2(a + 3) expands to 2a + 3.', NULL), (@activity, N'True', N'Like terms have exactly the same letters and powers.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Algebra Foundations' AND t.Title = N'Solving linear equations');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Equation and answer pairs')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Equation and answer pairs', N'Flip cards to pair each equation with its solution.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Memory');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'x + 4 = 9', N'x = 5', NULL), (@activity, N'2x = 14', N'x = 7', NULL), (@activity, N'x - 3 = 8', N'x = 11', NULL), (@activity, N'3x + 1 = 10', N'x = 3', NULL), (@activity, N'x / 2 = 6', N'x = 12', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Statistics You Can Use' AND t.Title = N'Averages and spread');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Statistics measures match')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Statistics measures match', N'Match each measure to how it is worked out.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Mean', N'Add the values and divide by how many there are', NULL), (@activity, N'Median', N'The middle value when sorted', NULL), (@activity, N'Mode', N'The value that appears most often', NULL), (@activity, N'Range', N'Largest value minus smallest value', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Statistics You Can Use' AND t.Title = N'Reading charts critically');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Fair chart or misleading?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Fair chart or misleading?', N'Sort each chart choice into fair or misleading.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Fair'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Axis starts at zero for bar charts', NULL, @group), (@activity, N'Labelled axes with units', NULL, @group), (@activity, N'Source of the data shown', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Misleading'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Cut-off axis that exaggerates a change', NULL, @group), (@activity, N'3D effects that distort size', NULL, @group), (@activity, N'Cherry-picked time period', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Academic Writing Essentials' AND t.Title = N'Planning and paragraphs');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Paragraph parts')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Paragraph parts', N'Type the missing term in each sentence about paragraphs.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'FillBlank');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'topic', N'The ___ sentence states the main point of a paragraph.', NULL), (@activity, N'evidence', N'Quotes and data are the ___ that support your point.', NULL), (@activity, N'analysis', N'Explaining what the evidence shows is called ___.', NULL), (@activity, N'link', N'A ___ sentence connects the paragraph back to the question.', NULL), (@activity, N'outline', N'An ___ is a plan of the essay''s main points.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Academic Writing Essentials' AND t.Title = N'Sources and referencing');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Referencing true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Referencing true or false', N'Is each statement about sources and referencing true?', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'Paraphrased ideas still need a citation.', NULL), (@activity, N'False', N'Information from a website never needs referencing.', NULL), (@activity, N'True', N'A reference list gives full details of every source cited.', NULL), (@activity, N'True', N'Peer-reviewed journals are usually more reliable than blogs.', NULL), (@activity, N'False', N'Changing a few words in a quote makes it your own work.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Presenting with Confidence' AND t.Title = N'Structure and slides');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Order a talk')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Order a talk', N'Put the parts of a short presentation in order.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sequence');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Hook the audience with a question or fact', N'1', NULL), (@activity, N'Say what the talk will cover', N'2', NULL), (@activity, N'Present your main points with examples', N'3', NULL), (@activity, N'Summarise the key message', N'4', NULL), (@activity, N'Invite questions', N'5', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Presenting with Confidence' AND t.Title = N'Voice, nerves and questions');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Nerves and fixes')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Nerves and fixes', N'Flip cards to pair each problem with a fix.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Memory');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Speaking too fast', N'Pause after each key point', NULL), (@activity, N'Shaky hands', N'Hold a clicker or rest them on the stand', NULL), (@activity, N'Mind goes blank', N'Glance at a short cue card', NULL), (@activity, N'No eye contact', N'Look at three friendly faces in turn', NULL), (@activity, N'Hard question', N'Thank them and offer to follow up later', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Python Programming from Zero' AND t.Title = N'First steps in Python');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Python function match')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Python function match', N'Match each built-in function to what it does.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'print()', N'Shows a value on screen', NULL), (@activity, N'input()', N'Reads text typed by the user', NULL), (@activity, N'len()', N'Counts the items or characters', NULL), (@activity, N'int()', N'Turns text into a whole number', NULL), (@activity, N'type()', N'Tells you what kind of value it is', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Python Programming from Zero' AND t.Title = N'Decisions and loops');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Python logic true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Python logic true or false', N'Decide whether each statement about Python is true.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'Python uses indentation to show which lines belong to an if.', NULL), (@activity, N'False', N'elif must come before if.', NULL), (@activity, N'True', N'range(3) gives 0, 1 and 2.', NULL), (@activity, N'True', N'== compares two values, while = assigns one.', NULL), (@activity, N'False', N'A while loop always runs at least once.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Python Programming from Zero' AND t.Title = N'Functions and lists');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'List method or string method?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'List method or string method?', N'Sort each method into list methods or string methods.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'List methods'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'append()', NULL, @group), (@activity, N'pop()', NULL, @group), (@activity, N'sort()', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'String methods'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'upper()', NULL, @group), (@activity, N'split()', NULL, @group), (@activity, N'strip()', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'AI Foundations: How Machines Learn' AND t.Title = N'What counts as AI');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'AI or not AI?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'AI or not AI?', N'Sort each system into examples of AI and ordinary programs.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'AI'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Spam filter that learns from examples', NULL, @group), (@activity, N'Photo app that recognises faces', NULL, @group), (@activity, N'Voice assistant understanding speech', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Not AI'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Calculator adding numbers', NULL, @group), (@activity, N'Alarm clock at a set time', NULL, @group), (@activity, N'Spreadsheet total formula', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'AI Foundations: How Machines Learn' AND t.Title = N'How a model learns');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Machine learning blanks')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Machine learning blanks', N'Type the missing machine learning term.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'FillBlank');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'training', N'A model learns patterns from ___ data.', NULL), (@activity, N'labels', N'In supervised learning, examples come with the correct ___.', NULL), (@activity, N'test', N'Data kept aside to check the model is the ___ set.', NULL), (@activity, N'overfitting', N'Memorising the training data instead of learning general patterns is ___.', NULL), (@activity, N'prediction', N'The model''s output for a new example is a ___.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'AI Foundations: How Machines Learn' AND t.Title = N'Limits and fairness');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'AI fairness flashcards')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'AI fairness flashcards', N'Flip each card to check the meaning, then rate yourself.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Flashcards');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Bias', N'Results that unfairly favour or harm a group', NULL), (@activity, N'Training data gap', N'Groups missing from the data the model learned from', NULL), (@activity, N'Hallucination', N'A confident answer that is made up', NULL), (@activity, N'Transparency', N'Being open about how a system makes decisions', NULL), (@activity, N'Human oversight', N'A person checking important AI decisions', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Network Security Basics' AND t.Title = N'How data travels');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Loading a web page')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Loading a web page', N'Put the steps of loading a web page in order.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sequence');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'You type a web address', N'1', NULL), (@activity, N'DNS finds the server''s IP address', N'2', NULL), (@activity, N'Your browser sends a request to the server', N'3', NULL), (@activity, N'The server sends back the page', N'4', NULL), (@activity, N'The browser displays the page', N'5', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Network Security Basics' AND t.Title = N'Keeping networks safe');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Security word scramble')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Security word scramble', N'Unscramble each security word using its hint.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Scramble');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'firewall', N'Filters traffic coming into a network', NULL), (@activity, N'encryption', N'Scrambles data so only the right key can read it', NULL), (@activity, N'malware', N'Software made to cause harm', NULL), (@activity, N'patch', N'An update that fixes a security hole', NULL), (@activity, N'phishing', N'Tricking people into giving away details', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Exam Revision Strategies' AND t.Title = N'Planning revision');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Revision technique pairs')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Revision technique pairs', N'Flip cards to pair each technique with what it means.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Memory');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Spaced practice', N'Review topics over several days', NULL), (@activity, N'Retrieval practice', N'Recall answers from memory', NULL), (@activity, N'Interleaving', N'Mix different topics in one session', NULL), (@activity, N'Past papers', N'Practise real exam questions', NULL), (@activity, N'Flashcards', N'Quick question and answer cards', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Exam Revision Strategies' AND t.Title = N'Practising and the exam day');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Before or during the exam?')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Before or during the exam?', N'Sort each tip into before the exam or during the exam.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Sort');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'Before'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Check the exam time and room', NULL, @group), (@activity, N'Sleep well the night before', NULL, @group), (@activity, N'Pack pens and ID', NULL, @group);
    INSERT dbo.GameGroup (ActivityID, GroupName) VALUES (@activity, N'During'); SET @group = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Read every question carefully', NULL, @group), (@activity, N'Plan time for each section', NULL, @group), (@activity, N'Check your answers at the end', NULL, @group);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Time Management for Students' AND t.Title = N'Priorities');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Priority matrix match')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Priority matrix match', N'Match each type of task to what you should do with it.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Urgent and important', N'Do it now', NULL), (@activity, N'Important, not urgent', N'Schedule it', NULL), (@activity, N'Urgent, not important', N'Delegate or keep it short', NULL), (@activity, N'Neither', N'Drop it', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Time Management for Students' AND t.Title = N'Beating procrastination');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Procrastination true or false')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Procrastination true or false', N'Decide whether each statement about procrastination is true.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'TrueFalse');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'True', N'Breaking a task into small steps makes it easier to start.', NULL), (@activity, N'False', N'Waiting until you feel motivated is the best plan.', NULL), (@activity, N'True', N'Removing distractions helps you keep going.', NULL), (@activity, N'True', N'A short timer can help you start a task you are avoiding.', NULL), (@activity, N'False', N'Multitasking gets more done than focusing on one thing.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Using AI Tools Responsibly' AND t.Title = N'Writing good prompts');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Prompt writing blanks')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Prompt writing blanks', N'Type the missing word in each prompt-writing tip.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'FillBlank');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'context', N'Give the AI ___ about who you are and what you need.', NULL), (@activity, N'format', N'Say what ___ you want, such as a table or bullet points.', NULL), (@activity, N'example', N'An ___ of the style you want improves the answer.', NULL), (@activity, N'specific', N'A ___ question gets a more useful answer than a vague one.', NULL), (@activity, N'check', N'Always ___ the answer against a reliable source.', NULL);
END

SET @topic = (SELECT t.TopicID FROM dbo.Topic t JOIN dbo.Course c ON c.CourseID = t.CourseID WHERE c.Title = N'Using AI Tools Responsibly' AND t.Title = N'Checking and integrity');
IF @topic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Activity WHERE TopicID = @topic AND Title = N'Integrity terms match')
BEGIN
    INSERT dbo.Activity (TopicID, ActivityType, Title, Description, Status, SortOrder, GameTemplate)
    VALUES (@topic, 'Game', N'Integrity terms match', N'Match each academic integrity term to its meaning.', 'Published', (SELECT ISNULL(MAX(SortOrder), 0) + 1 FROM dbo.Activity WHERE TopicID = @topic), 'Matching');
    SET @activity = SCOPE_IDENTITY();
    INSERT dbo.GameItem (ActivityID, ItemText, MatchText, GroupID) VALUES (@activity, N'Plagiarism', N'Presenting someone else''s work as your own', NULL), (@activity, N'Citation', N'Showing where an idea came from', NULL), (@activity, N'Fact-checking', N'Confirming a claim with trusted sources', NULL), (@activity, N'Disclosure', N'Saying when and how you used an AI tool', NULL), (@activity, N'Original work', N'Ideas and wording that are your own', NULL);
END

SELECT COUNT(*) AS GamesNow FROM dbo.Activity WHERE ActivityType = 'Game';
