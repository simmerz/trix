#= require trix/views/text_view
#= require fixtures

module "Trix.TextView"


test "#constructor", ->
  element = document.createElement("div")
  new Trix.TextView element, fixture("plain")
  equal element.trixPosition, 0, "element has a trixPosition property"


test "#render", ->
  element = document.createElement("div")
  view = new Trix.TextView element

  view.text = createText("a")
  view.render()
  equal element.textContent, "a", "rendered text"

  view.text = createText("b")
  view.render()
  equal element.textContent, "b", "replaced contents with text"


test "#createElementsForText", ->
  text = fixture("plain")
  elements = getElementsForText(text)
  equal elements.length, 1, "one element for plain string"

  el = elements[0]
  equal el.tagName.toLowerCase(), "span", "container element is a span"
  equal el.trixPosition, 0, "container element has a trixPosition"
  equal el.childNodes.length, 1, "container element has one child node"

  node = el.firstChild
  equal node.nodeType, Node.TEXT_NODE, "child node is a text node"
  equal node.data, text.toString(), "child node contains text string"
  equal node.trixPosition, 0, "child node has a trixPosition property"
  equal node.trixLength, text.getLength(), "child node has a trixLength property"

  elements = getElementsForText(createText(" !"))
  equal elements[0].firstChild.data, "\u00a0!", "leading space replaced with non-breaking space"

  elements = getElementsForText(createText("! "))
  equal elements[0].firstChild.data, "!\u00a0", "trailing space replaced with non-breaking space"

  elements = getElementsForText(createText("!   !"))
  equal elements[0].firstChild.data, "! \u00a0 !", "multiple spaces preserved with non-breaking spaces"

  elements = getElementsForText(createText("Hello\n"))
  equal elements.length, 2, "two elements for string ending with a newline"
  equal elements[0].lastChild.tagName.toLowerCase(), "br", "container element's last child is a BR"
  equal elements[1].tagName.toLowerCase(), "br", "last element is an extra BR"

  elements = getElementsForText(createText(".", bold: true))
  equal elements[0].tagName.toLowerCase(), "strong", "element is strong"

  elements = getElementsForText(createText(".", italic: true))
  equal elements[0].tagName.toLowerCase(), "em", "element is em"

  elements = getElementsForText(createText(".", underline: true))
  equal elements[0].style["text-decoration"], "underline", "text decoration is underline"

  elements = getElementsForText(createText(".", frozen: true))
  equal elements[0].style["background-color"], "highlight", "background color is highlight"

  elements = getElementsForText(fixture("linkWithFormatting"))
  equal elements.length, 1, "one element for a link with formatting"

  el = elements[0]
  equal el.tagName.toLowerCase(), "a", "container element is an A"
  equal el.getAttribute("href"), "http://basecamp.com", "element has href attribute"

  [a, b] = el.childNodes
  equal a.tagName.toLowerCase(), "strong", "child element is strong"
  ok !a.getAttribute("href"), "child element has no href attribute"
  equal b.tagName.toLowerCase(), "span", "second child element is not styled"
  ok !b.getAttribute("href"), "second child element has no href attribute"


test "#getSelectedRange", ->
  view = installTextView(fixture("formatted"))
  element = view.element

  setRangeInNode(element.childNodes[0].firstChild, [1, 5], "ello")
  deepEqual view.getSelectedRange(), [1, 5], "range is positions in text"

  setRangeInNode(element.childNodes[1].firstChild.firstChild, [0, 2], "ri")
  deepEqual view.getSelectedRange(), [7, 9], "range is positions in text"

  setRangeInNode(element.childNodes[2].firstChild, [2, 3], "x")
  deepEqual view.getSelectedRange(), [14, 15], "range is positions in text"


test "#setSelectedRange", ->
  view = installTextView(fixture("formatted"))
  element = view.element

  view.setSelectedRange([1, 5])
  rangeInNodeAroundString(element.childNodes[0].firstChild, "ello")

  view.setSelectedRange([7, 9])
  rangeInNodeAroundString(element.childNodes[1].firstChild.firstChild, "ri")

  view.setSelectedRange([14, 15])
  rangeInNodeAroundString(element.childNodes[2].firstChild, "x")


# Helpers

getElementsForText = (text) ->
  element = document.createElement("div")
  textView = new Trix.TextView element, text
  textView.createElementsForText()

createText = (string, attributes) ->
  Trix.Text.textForStringWithAttributes(string, attributes)

installTextView = (text) ->
  element = document.createElement("div")
  document.body.appendChild(element)
  view = new Trix.TextView element, text
  view.render()
  view

setRangeInNode = (node, [startOffset, endOffset], expectedString) ->
  range = document.createRange()
  range.setStart(node, startOffset)
  range.setEnd(node, endOffset)

  selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range)

  equal range.toString(), expectedString, "range set around expected string"

rangeInNodeAroundString = (node, string) ->
  range = window.getSelection().getRangeAt(0)
  equal range.startContainer, node, "range starts in correct node"
  equal range.toString(), string, "range set around expected string"

