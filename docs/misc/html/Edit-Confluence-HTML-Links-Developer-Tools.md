# EDIT A Confluence Page's HTML

Chrome's 3 dots -> More Tools -> Developer Tools
Console Tab at the top

## Step 1

Type the following into the console at the bottom of the page:

allow pasting

You can now paste the following code into the console

## Step 2

```html
(() => {
  const ed = window.tinymce && tinymce.activeEditor;
  if (!ed) return console.log("No TinyMCE activeEditor found (are you in the classic editor?).");

  const oldDomain = "tcode.mil";
  const newDomain = "tcode.transport.mil";

  const html = ed.getContent({ format: "raw" });

  // Count *case-insensitive* occurrences
  const reOld = new RegExp(oldDomain.replace(/\./g, "\\."), "gi");
  const before = (html.match(reOld) || []).length;

  console.log("Occurrences before (case-insensitive):", before);

  if (before === 0) {
    // Help you diagnose what IS in the HTML
    const sample = html.match(/https?:\/\/[^"' <>()]+/gi) || [];
    console.log("No matches. Sample URLs from editor HTML (first 30):");
    console.log(sample.slice(0, 30));
    return;
  }

  const updated = html.replace(reOld, newDomain);

  ed.setContent(updated, { format: "raw" });
  ed.setDirty(true);
  ed.nodeChanged();

  const afterHtml = ed.getContent({ format: "raw" });
  const after = (afterHtml.match(reOld) || []).length;

  console.log("Occurrences after:", after);
  console.log("Now click Save/Publish.");
})();

## Step 3

Then run the following:

(() => {
  const ed = window.tinymce && tinymce.activeEditor;
  const c = (ed.getContent({format:"raw"}).match(/website\.mil/g) || []).length;
  console.log("Still remaining in editor HTML:", c);
})();
```

## Step 4

Save and exit "edit" mode


## BONUS

### Remove Green Boxes

```html
(() => {
  const ed = window.tinymce && tinymce.activeEditor;
  if (!ed) return console.log("No TinyMCE activeEditor found. Are you in Edit mode?");

  const beforeHtml = ed.getContent({ format: "raw" });

  // 1) Remove outline declarations specifically inside style=""
  //    Works with:
  //    - outline: green solid 2.0px;
  //    - outline: 2px solid green;
  //    - any ordering/spacing/casing
  let afterHtml = beforeHtml.replace(
    /(style="[^"]*?)\boutline\s*:\s*[^;"]+;?\s*([^"]*")/gi,
    (m, p1, p2) => p1 + p2
  );

  // 2) Clean up style="" that became empty or whitespace-only
  afterHtml = afterHtml
    .replace(/\sstyle="\s*"\s*/gi, " ")
    .replace(/\sstyle="\s*;\s*"\s*/gi, " "); // handles weird leftover semicolons

  const beforeCount = (beforeHtml.match(/\boutline\s*:/gi) || []).length;
  const afterCount  = (afterHtml.match(/\boutline\s*:/gi) || []).length;

  console.log(`outline declarations before: ${beforeCount}`);
  console.log(`outline declarations after : ${afterCount}`);

  if (beforeHtml === afterHtml) {
    console.log("No changes made. If you still see green boxes, the outline may be injected at render-time by a macro/theme/app.");
    return;
  }

  ed.setContent(afterHtml, { format: "raw" });
  ed.setDirty(true);
  ed.nodeChanged();

  console.log("Applied. Now click Save/Publish.");
})();

```
