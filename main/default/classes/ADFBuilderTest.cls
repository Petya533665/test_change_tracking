@IsTest
public with sharing class ADFBuilderTest {

	@IsTest
	private static void testBasicTextAndFormatting() {
		ADFBuilder builder = new ADFBuilder();

		builder.addText('Hello world')
				.addFormattedText('Bold', 'strong')
				.addFormattedText('Italic', 'em')
				.addLink('https://example.com', 'Link');

		Map<String, Object> doc = builder.build();
		String jsonStr = builder.buildJSON();

		System.assertEquals('doc', doc.get('type'));
		System.assertEquals(1, doc.get('version'));

		List<Object> content = (List<Object>)doc.get('content');
		System.assertEquals(1, content.size(), 'Should be one paragraph');

		Map<String, Object> paragraph = (Map<String, Object>)content[0];
		System.assertEquals('paragraph', paragraph.get('type'));

		List<Object> paraContent = (List<Object>)paragraph.get('content');
		System.assertEquals(4, paraContent.size(), 'Should have text, bold, italic, and link nodes');

		// Check specific nodes
		Map<String, Object> node1 = (Map<String, Object>)paraContent[0];
		System.assertEquals('text', node1.get('type'));
		System.assertEquals('Hello world', node1.get('text'));

		Map<String, Object> node2 = (Map<String, Object>)paraContent[1];
		List<Object> marks = (List<Object>)node2.get('marks');
		Map<String, Object> mark = (Map<String, Object>)marks[0];
		System.assertEquals('strong', mark.get('type'));

		System.assert(jsonStr.contains('Hello world'));
	}

	@IsTest
	private static void testStructureBlocks() {
		ADFBuilder builder = new ADFBuilder();

		builder.addHeading(1, 'Title')
				.addHeading(7, 'Small Title') // Should default to 1 or valid range logic
				.addCodeBlock('System.debug("Hi");', 'java')
				.addText('Some text')
				.addHardBreak()
				.addText('New line');

		Map<String, Object> doc = builder.build();
		List<Object> content = (List<Object>)doc.get('content');

		// 1. Heading 1
		Map<String, Object> h1 = (Map<String, Object>)content[0];
		System.assertEquals('heading', h1.get('type'));

		// 2. Heading (fallback logic check)
		Map<String, Object> h2 = (Map<String, Object>)content[1];
		System.assertEquals('heading', h2.get('type'));

		// 3. Code Block
		Map<String, Object> cb = (Map<String, Object>)content[2];
		System.assertEquals('codeBlock', cb.get('type'));
		Map<String, Object> attrs = (Map<String, Object>)cb.get('attrs');
		System.assertEquals('java', attrs.get('language'));

		// 4. Paragraph with HardBreak
		Map<String, Object> para = (Map<String, Object>)content[3];
		List<Object> paraContent = (List<Object>)para.get('content');
		System.assertEquals(3, paraContent.size()); // Text, HardBreak, Text
		Map<String, Object> br = (Map<String, Object>)paraContent[1];
		System.assertEquals('hardBreak', br.get('type'));
	}

	@IsTest
	private static void testLists() {
		ADFBuilder builder = new ADFBuilder();
		List<String> items = new List<String>{'Item 1', 'Item 2'};

		builder.addBulletList(items)
				.addOrderedList(items);

		Map<String, Object> doc = builder.build();
		List<Object> content = (List<Object>)doc.get('content');

		Map<String, Object> bulletList = (Map<String, Object>)content[0];
		System.assertEquals('bulletList', bulletList.get('type'));
		List<Object> bItems = (List<Object>)bulletList.get('content');
		System.assertEquals(2, bItems.size());

		Map<String, Object> orderedList = (Map<String, Object>)content[1];
		System.assertEquals('orderedList', orderedList.get('type'));
	}

	@IsTest
	private static void testTable() {
		ADFBuilder builder = new ADFBuilder();

		List<String> headers = new List<String>{'Col 1', 'Col 2'};
		List<List<String>> rows = new List<List<String>>();
		rows.add(new List<String>{'Val 1', 'Val 2'});

		builder.addTable(headers, rows);

		Map<String, Object> doc = builder.build();
		List<Object> content = (List<Object>)doc.get('content');
		Map<String, Object> table = (Map<String, Object>)content[0];

		System.assertEquals('table', table.get('type'));
		List<Object> tableContent = (List<Object>)table.get('content');
		System.assertEquals(2, tableContent.size()); // Header row + 1 data row

		// Check Header Row
		Map<String, Object> row1 = (Map<String, Object>)tableContent[0];
		List<Object> cells1 = (List<Object>)row1.get('content');
		Map<String, Object> cell1 = (Map<String, Object>)cells1[0];
		System.assertEquals('tableHeader', cell1.get('type'));

		// Check Data Row
		Map<String, Object> row2 = (Map<String, Object>)tableContent[1];
		List<Object> cells2 = (List<Object>)row2.get('content');
		Map<String, Object> cell2 = (Map<String, Object>)cells2[0];
		System.assertEquals('tableCell', cell2.get('type'));
	}

	@IsTest
	private static void testMediaAndParagraphs() {
		ADFBuilder builder = new ADFBuilder();

		builder.addText('Start')
				.newParagraph()
				.addMedia('12345', 'Alt Text');

		Map<String, Object> doc = builder.build();
		List<Object> content = (List<Object>)doc.get('content');

		System.assertEquals(2, content.size());

		Map<String, Object> para1 = (Map<String, Object>)content[0]; // Contains "Start"
		Map<String, Object> para2 = (Map<String, Object>)content[1]; // Contains Media

		List<Object> p2Content = (List<Object>)para2.get('content');
		Map<String, Object> media = (Map<String, Object>)p2Content[0];
		System.assertEquals('media', media.get('type'));
		Map<String, Object> attrs = (Map<String, Object>)media.get('attrs');
		System.assertEquals('12345', attrs.get('id'));
		System.assertEquals('Alt Text', attrs.get('alt'));
	}

	@IsTest
	private static void testAppendDoc() {
		// Doc 1
		Map<String, Object> doc1 = new ADFBuilder().addText('Part 1').build();

		// Builder 2
		ADFBuilder builder = new ADFBuilder();
		builder.addHeading(1, 'Main Doc');
		builder.appendDoc(doc1);

		Map<String, Object> result = builder.build();
		List<Object> content = (List<Object>)result.get('content');

		System.assertEquals(2, content.size());
		Map<String, Object> node2 = (Map<String, Object>)content[1];
		System.assertEquals('paragraph', node2.get('type')); // doc1 content was a paragraph
	}

	@IsTest
	private static void testFromTextWithLinks() {
		// 1. Text with URL in the middle
		String text1 = 'Click https://google.com here';
		Map<String, Object> doc1 = ADFBuilder.fromTextWithLinks(text1);
		List<Object> c1 = (List<Object>)((Map<String, Object>)((List<Object>)doc1.get('content'))[0]).get('content');
		System.assertEquals(3, c1.size()); // text + link + text

		// 2. Text starting with URL
		String text2 = 'http://test.com is the site';
		Map<String, Object> doc2 = ADFBuilder.fromTextWithLinks(text2);
		List<Object> c2 = (List<Object>)((Map<String, Object>)((List<Object>)doc2.get('content'))[0]).get('content');
		System.assertEquals(2, c2.size()); // link + text

		// 3. Text ending with URL
		String text3 = 'Go to https://sf.com';
		Map<String, Object> doc3 = ADFBuilder.fromTextWithLinks(text3);
		List<Object> c3 = (List<Object>)((Map<String, Object>)((List<Object>)doc3.get('content'))[0]).get('content');
		System.assertEquals(2, c3.size()); // text + link

		// 4. No URL
		String text4 = 'Just text';
		Map<String, Object> doc4 = ADFBuilder.fromTextWithLinks(text4);
		List<Object> c4 = (List<Object>)((Map<String, Object>)((List<Object>)doc4.get('content'))[0]).get('content');
		System.assertEquals(1, c4.size()); // text

		// 5. Empty
		Map<String, Object> doc5 = ADFBuilder.fromTextWithLinks(null);
		List<Object> content5 = (List<Object>)doc5.get('content');
		// Depending on implementation, fromPlainText('') might return 1 empty paragraph node
		// let's check if it's valid doc structure
		System.assertNotEquals(null, content5);
	}

	@IsTest
	static void testEdgeCases() {
		ADFBuilder builder = new ADFBuilder();

		// Test null/empty inputs safe handling
		builder.addText(null)
				.addLink(null, null)
				.addFormattedText(null, 'strong')
				.addFormattedText('text', null)
				.addMedia(null, null)
				.addCodeBlock(null, null)
				.addHeading(1, null) // Empty text heading check
				.addBulletList(null)
				.addOrderedList(new List<String>())
				.addTable(null, null)
				.appendDoc(null);

		Map<String, Object> doc = builder.build();
		List<Object> content = (List<Object>)doc.get('content');
		System.assertEquals(0, content.size(), 'Doc should be empty as all inputs were invalid');

		// Test fromPlainText with null
		Map<String, Object> plainDoc = ADFBuilder.fromPlainText(null);
		System.assertEquals('doc', plainDoc.get('type'));
		System.assertEquals(0, ((List<Object>)plainDoc.get('content')).size());
	}

}