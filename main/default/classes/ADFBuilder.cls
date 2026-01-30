public with sharing class ADFBuilder {

	public static final String TYPE_TEXT = 'text';
	public static final String TYPE_LINK = 'link';
	public static final String TYPE_MEDIA = 'media';
	public static final String TYPE_FILE = 'file';
	public static final String TYPE_HARD_BREAK = 'hardBreak';
	public static final String TYPE_CODE_BLOCK = 'codeBlock';
	public static final String TYPE_HEADING = 'heading';
	public static final String TYPE_BULLET_LIST = 'bulletList';
	public static final String TYPE_ORDERED_LIST = 'orderedList';
	public static final String TYPE_PARAGRAPH = 'paragraph';
	public static final String TYPE_LIST_ITEM = 'listItem';
	public static final String TYPE_TABLE = 'table';
	public static final String TYPE_TABLE_HEADER = 'tableHeader';
	public static final String TYPE_TABLE_CELL = 'tableCell';
	public static final String TYPE_TABLE_ROW = 'tableRow';
	public static final String TYPE_DOC = 'doc';
	public static final String TYPE_MEDIA_SINGLE = 'mediaSingle';


	public static final String ATTR_TYPE = 'type';
	public static final String ATTR_TEXT = 'text';
	public static final String ATTR_MARKS = 'marks';
	public static final String ATTR_ATTRS = 'attrs';
	public static final String ATTR_HREF = 'href';
	public static final String ATTR_ID = Constants.GLOBAL_VARIABLE.JSON_KEY_ID;
	public static final String ATTR_COLLECTION = 'collection';
	public static final String ATTR_ALT = 'alt';
	public static final String ATTR_CONTENT = 'content';
	public static final String ATTR_LANGUAGE = 'language';
	public static final String ATTR_LEVEL = 'level';
	public static final String ATTR_VERSION = 'version';
	public static final String ATTR_BODY = 'body';
	public static final String ATTR_FIELDS = 'fields';
	public static final String ATTR_DESCRIPTION = 'description';
	public static final String ATTR_PROJECT = 'project';
	public static final String ATTR_ISSUE_TYPE = 'issuetype';
	public static final String ATTR_SUMMARY = 'summary';

	private static final Pattern REGEX_URL_PATTERN = Pattern.compile('(https?://[^\\s]+)');

	private List<Object> paragraphNodes = new List<Object>();
	private List<Object> documentContent = new List<Object>();
	private Boolean hasPendingParagraph = false;

	/**
	 * Add plain text node to current paragraph
	 * @param text Text content to add
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addText(String text) {
		if (String.isNotBlank(text)) {
			paragraphNodes.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_TEXT,
					ATTR_TEXT => text
			});
			hasPendingParagraph = true;
		}
		return this;
	}

	/**
	 * Add link node to current paragraph
	 * @param url The URL to link to
	 * @param displayText Text to display (if null, uses URL)
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addLink(String url, String displayText) {
		if (String.isNotBlank(url)) {
			paragraphNodes.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_TEXT,
					ATTR_TEXT => String.isNotBlank(displayText) ? displayText : url,
					ATTR_MARKS => new List<Object>{
							new Map<String, Object>{
									ATTR_TYPE => TYPE_LINK,
									ATTR_ATTRS => new Map<String, Object>{
											ATTR_HREF => url
									}
							}
					}
			});
			hasPendingParagraph = true;
		}
		return this;
	}

	/**
	 * Add formatted text node (bold, italic, code, etc.)
	 * @param text Text content
	 * @param markType Type of formatting ('strong', 'em', 'code', 'strike', 'underline')
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addFormattedText(String text, String markType) {
		if (String.isNotBlank(text) && String.isNotBlank(markType)) {
			paragraphNodes.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_TEXT,
					ATTR_TEXT => text,
					ATTR_MARKS => new List<Object>{
							new Map<String, Object>{
									ATTR_TYPE => markType
							}
					}
			});
			hasPendingParagraph = true;
		}
		return this;
	}

	/**
	 * Add media/attachment node to current paragraph
	 * @param attachmentId Jira attachment ID or URL
	 * @param altText Alternative text for the media
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addMedia(String attachmentId, String altText) {
		if (String.isNotBlank(attachmentId)) {
			paragraphNodes.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_MEDIA,
					ATTR_ATTRS => new Map<String, Object>{
							ATTR_ID => attachmentId,
							ATTR_TYPE => TYPE_FILE,
							ATTR_COLLECTION => '',
							ATTR_ALT => String.isNotBlank(altText) ? altText : ''
					}
			});
			hasPendingParagraph = true;
		}
		return this;
	}

	/**
	 * Add hard break (line break) inside current paragraph
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addHardBreak() {
		paragraphNodes.add(new Map<String, Object>{
				ATTR_TYPE => TYPE_HARD_BREAK
		});
		hasPendingParagraph = true;
		return this;
	}

	/**
	 * Add code block (pre-formatted text)
	 * @param code Code content
	 * @param language Language identifier (optional)
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addCodeBlock(String code, String language) {
		finalizeParagraph();
		if (String.isNotBlank(code)) {
			Map<String, Object> attrs = new Map<String, Object>();
			if (String.isNotBlank(language)) {
				attrs.put(ATTR_LANGUAGE, language);
			}
			documentContent.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_CODE_BLOCK,
					ATTR_ATTRS => attrs,
					ATTR_CONTENT => new List<Object>{
							new Map<String, Object>{
									ATTR_TYPE => TYPE_TEXT,
									ATTR_TEXT => code
							}
					}
			});
		}
		return this;
	}

	/**
	 * Add heading block (h1..h6)
	 * @param level Heading level (1..6)
	 * @param text Heading text
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addHeading(Integer level, String text) {
		finalizeParagraph();
		if (String.isBlank(text)) {
			return this;
		}
		if (level == null || level < 1 || level > 6) {
			level = 1;
		}
		documentContent.add(new Map<String, Object>{
				ATTR_TYPE => TYPE_HEADING,
				ATTR_ATTRS => new Map<String, Object>{ ATTR_LEVEL => level },
				ATTR_CONTENT => new List<Object>{
						new Map<String, Object>{
								ATTR_TYPE => TYPE_TEXT,
								ATTR_TEXT => text
						}
				}
		});
		return this;
	}

	/**
	 * Start a new paragraph (finalizes current one)
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder newParagraph() {
		finalizeParagraph();
		return this;
	}

	/**
	 * Add bullet list from list of strings
	 * @param items List items
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addBulletList(List<String> items) {
		return addList(items, TYPE_BULLET_LIST);
	}

	/**
	 * Add ordered list from list of strings
	 * @param items List items
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addOrderedList(List<String> items) {
		return addList(items, TYPE_ORDERED_LIST);
	}

	/**
	 * Internal helper to add list node
	 */
	private ADFBuilder addList(List<String> items, String listType) {
		finalizeParagraph();
		if (items == null || items.isEmpty()) {
			return this;
		}

		List<Object> listItems = new List<Object>();
		for (String itemText : items) {
			if (itemText == null) itemText = '';
			Map<String, Object> paragraph = new Map<String, Object>{
					ATTR_TYPE => TYPE_PARAGRAPH,
					ATTR_CONTENT => new List<Object>{
							new Map<String, Object>{
									ATTR_TYPE => TYPE_TEXT,
									ATTR_TEXT => itemText
							}
					}
			};
			listItems.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_LIST_ITEM,
					ATTR_CONTENT => new List<Object>{ paragraph }
			});
		}

		documentContent.add(new Map<String, Object>{
				ATTR_TYPE => listType,
				ATTR_CONTENT => listItems
		});
		return this;
	}

	/**
	 * Add simple table
	 * @param header Header row (may be null)
	 * @param rows   Data rows
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder addTable(List<String> header, List<List<String>> rows) {
		finalizeParagraph();

		List<Object> tableRows = new List<Object>();

		if (header != null && !header.isEmpty()) {
			tableRows.add(buildTableRow(header, true));
		}
		if (rows != null) {
			for (List<String> r : rows) {
				tableRows.add(buildTableRow(r, false));
			}
		}

		if (!tableRows.isEmpty()) {
			documentContent.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_TABLE,
					ATTR_CONTENT => tableRows
			});
		}
		return this;
	}

	private Map<String, Object> buildTableRow(List<String> cells, Boolean isHeader) {
		List<Object> cellNodes = new List<Object>();
		for (String cellText : cells) {
			if (cellText == null) cellText = '';
			Map<String, Object> paragraph = new Map<String, Object>{
					ATTR_TYPE => TYPE_PARAGRAPH,
					ATTR_CONTENT => new List<Object>{
							new Map<String, Object>{
									ATTR_TYPE => TYPE_TEXT,
									ATTR_TEXT => cellText
							}
					}
			};
			cellNodes.add(new Map<String, Object>{
					ATTR_TYPE => isHeader ? TYPE_TABLE_HEADER : TYPE_TABLE_CELL,
					ATTR_CONTENT => new List<Object>{ paragraph }
			});
		}
		return new Map<String, Object>{
				ATTR_TYPE => TYPE_TABLE_ROW,
				ATTR_CONTENT => cellNodes
		};
	}

	/**
	 * Append content of another ADF doc to current document
	 * @param otherDoc ADF document (Map with type=doc)
	 * @return this (for fluent chaining)
	 */
	public ADFBuilder appendDoc(Map<String, Object> otherDoc) {
		if (otherDoc == null) {
			return this;
		}
		List<Object> otherContent = (List<Object>) otherDoc.get(ATTR_CONTENT);
		if (otherContent != null && !otherContent.isEmpty()) {
			finalizeParagraph();
			documentContent.addAll(otherContent);
		}
		return this;
	}

	/**
	 * Finalize current paragraph and add to document
	 */
	private void finalizeParagraph() {
		if (hasPendingParagraph && !paragraphNodes.isEmpty()) {
			documentContent.add(new Map<String, Object>{
					ATTR_TYPE => TYPE_PARAGRAPH,
					ATTR_CONTENT => paragraphNodes
			});
			paragraphNodes = new List<Object>();
			hasPendingParagraph = false;
		}
	}

	/**
	 * Build final ADF document structure
	 * @return Complete ADF document as Map
	 */
	public Map<String, Object> build() {
		finalizeParagraph();

		// If no content, return minimal valid ADF
		if (documentContent.isEmpty()) {
			return new Map<String, Object>{
					ATTR_TYPE => TYPE_DOC,
					ATTR_VERSION => 1,
					ATTR_CONTENT => new List<Object>()
			};
		}

		return new Map<String, Object>{
				ATTR_TYPE => TYPE_DOC,
				ATTR_VERSION => 1,
				ATTR_CONTENT => documentContent
		};
	}

	/**
	 * Build and return as JSON string
	 * @return JSON string representation of ADF document
	 */
	public String buildJSON() {
		return JSON.serialize(build());
	}

	/**
	 * Static helper: Create ADF from plain text (backward compatibility)
	 * @param text Plain text content
	 * @return ADF document
	 */
	public static Map<String, Object> fromPlainText(String text) {
		return new ADFBuilder().addText(text).build();
	}

	/**
	 * Static helper: Create ADF from text with auto-detected links
	 * @param content Text content that may contain URLs
	 * @return ADF document with links
	 */
	public static Map<String, Object> fromTextWithLinks(String content) {
		if (String.isBlank(content)) {
			return fromPlainText('');
		}

		ADFBuilder builder = new ADFBuilder();
		Pattern urlPattern = REGEX_URL_PATTERN;
		Matcher urlMatcher = urlPattern.matcher(content);

		Integer lastEnd = 0;
		while (urlMatcher.find()) {
			Integer start = urlMatcher.start();
			Integer endPos = urlMatcher.end();
			String url = urlMatcher.group(1);

			if (start > lastEnd) {
				builder.addText(content.substring(lastEnd, start));
			}
			builder.addLink(url, url);
			lastEnd = endPos;
		}

		if (lastEnd < content.length()) {
			builder.addText(content.substring(lastEnd));
		}

		return builder.build();
	}
}