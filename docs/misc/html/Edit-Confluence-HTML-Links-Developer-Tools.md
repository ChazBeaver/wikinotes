# EDIT A Confluence Page's HTML

Chrome's 3 dots -> More Tools -> Developer Tools
Console Tab at the top

## Step 1

Type the following into the console at the bottom of the page:

allow pasting

You can now paste the following code into the console

## Step 2

(() => {
  const ed = window.tinymce && tinymce.activeEditor;
  if (!ed) return console.log("No TinyMCE activeEditor found.");

  const oldDomain = "website.mil";
  const newDomain = "website.transport.mil";

  // Get the exact HTML that Confluence will serialize
  const html = ed.getContent({ format: "raw" });

  const before = (html.match(/website\.mil/g) || []).length;
  console.log("Occurrences before:", before);

  if (before === 0) {
    console.log("No occurrences found in editor HTML. This may be macro-generated content.");
    return;
  }

  const updated = html.replace(/website\.mil/g, newDomain);

  // Force TinyMCE to adopt the updated HTML as the document source of truth
  ed.setContent(updated, { format: "raw" });

  // Mark dirty + refresh
  ed.setDirty(true);
  ed.nodeChanged();

  const afterHtml = ed.getContent({ format: "raw" });
  const after = (afterHtml.match(/website\.mil/g) || []).length;
  console.log("Occurrences after:", after);

  console.log("Now click Save/Publish. If it still reverts, the URLs are being injected by macros or smart-link resolution.");
})();

## Step 3

Then run the following:

(() => {
  const ed = window.tinymce && tinymce.activeEditor;
  const c = (ed.getContent({format:"raw"}).match(/website\.mil/g) || []).length;
  console.log("Still remaining in editor HTML:", c);
})();

## Step 4

Save and exit "edit" mode
