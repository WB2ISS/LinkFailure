# Link Failure
#### Demonstrates WKWebView correctly processing links to anchors within a document on iOS/iPadOS and failing on macOS Catalyst.

In HTML that is included within the app bundle to be rendered by a WKWebView, a link target may be a URL pointing to a location on the Web, and a link target may also be an anchor within the HTML document.  For example, a link to an anchor within the document might have the form:

	<a href="#1.Overview">1. Overview</a>

and the corresponding anchor within the document could have the form:

	<span id="1.Overview"></span>
	
When the link is selected, the desired behavior is that the document scroll down to the anchor point.  

When a link target is a URL on the Web, the page may be rendered within the WKWebView. But in some cases it might be desirable to open the page in a browser instance external to the WKWebView so as to have a full Web browsing capability from that page.  WKWebView enables this behavior via the <code>WKNavigationDelegate</code> protocol and the <code>webView(_:decidePolicyFor:decisionHandler:)</code> method.  On iOS and iPadOS the <code>UIApplication.shared.canOpenURL(\_:)</code> method returns true if the link is to a URL on the Web and false if the link is to an anchor within a page. So a simple test can be made as follows:

	if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
		UIApplication.shared.open(url)
		decisionHandler(.cancel)
	} else {
		decisionHandler(.allow)
	}

A link to a URL on the Web will be opened in a browser external to the WKWebView, and a link to an anchor within the page will not, but will instead cause the page in the WKWebView to scroll to the anchor point.

On macOS Catalyst the same code has a different behavior.  On macOS Catalyst, when a URL points to an anchor within a page of HTML that is included in the app bundle, the <code>UIApplication.shared.canOpenURL(\_:)</code> check returns true, and instead of scrolling the WKWebView to the anchor point, the page is opened in an instance of the Safari browser (and positioned at the top of the page, not at the link target anchor).   In the case of a link to an anchor within the page of HTML included within the app bundle, the url has a "file" scheme.   On iOS/iPadOS a reference of this type can not be opened by Safari.  But apparently on macOS Catalyst it can.   So the <code>canOpenURL(\_:)</code> check returns false on iOS/iPadOS and true on macOS Catalyst.  This should not happen - it causes exactly the same code to behave in one way on iOS/iPadOS and in a completely different way on macOS Catalyst. While the different behavior of the <code>canOpenURL(\_:)</code> check might correctly reflects the different behavior of the browser on the two types of platforms, this difference breaks code that works correctly on iOS/iPadOS.  

A workaround is not complicated. For example, the following does the job:

	if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url), url.scheme != "file" {
		UIApplication.shared.open(url)
		decisionHandler(.cancel)
	} else {
		decisionHandler(.allow)
	}

On iOS/iPadOS a link to an anchor within the document will fail the  <code>canOpenURL(\_:)</code> check.  On macOS Catalyst the same link will pass that check, but will fail the following test that ensures that the link is only opened in an external browser when it doesn't use the "file" scheme.

Although this workaround mitigates the problem, it is important to realize that when the problem is first observed on macOS Catalyst in the form of a link to an internal anchor not working, it is not immediately obvious why this is happening or what to do about it.  It just looks like the link which worked properly on iOS/iPadOS is not working properly on macOS Catalyst.

This project demonstrates the problem and the workaround.  The HTML HelpFile document contains both internal links to anchors within the page, and external links to URLs on the Web.  On iOS and iPadOS the internal links scroll the page within the WKWebView to the anchor point, and the external links to URLs on the Web open in a browser external to the app.  But on macOS Catalyst both the internal and external links open in an external browser.  The workaround is simply to only open the link in an external browser when the URL scheme is not "file" . 