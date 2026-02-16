
import re

# Read new homepage
with open('index_new.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Read survey snippet
with open('survey_snippet.html', 'r', encoding='utf-8') as f:
    survey_html = f.read()

# Regex to find the Audit Section
# It starts with <section id="audit" ...> and ends with </section>
# But there might be other sections.
# We know the new content has:
# <!-- HIGH INTENT AUDIT FORM -->
# <section id="audit" ...>
# ...
# </section>

# We'll use a specific replacement.
pattern = r'(<!-- HIGH INTENT AUDIT FORM -->\s*<section id="audit".*?</section>)'
# Note: re.DOTALL is needed for .* to match newlines
match = re.search(pattern, content, re.DOTALL)

if match:
    print("Found Audit Section. Replacing...")
    new_content = content.replace(match.group(1), survey_html)
else:
    print("Audit Section NOT found via regex. Trying simple find.")
    # Fallback: Find strictly by ID if the comment is missing or different
    start_tag = '<section id="audit"'
    end_tag = '</section>'
    start_idx = content.find(start_tag)
    if start_idx != -1:
        # Find the closing tag for this section. Nesting makes this hard with simple find, 
        # but the provided HTML has clearly defined sections.
        # Let's assume the next </section> after a significant chunk is it, 
        # or better, search for the next <!-- FOOTER --> to be safe as a boundary?
        # The audit section is followed by <!-- FOOTER -->
        footer_idx = content.find('<!-- FOOTER -->')
        if footer_idx != -1:
            # Replace everything from start_tag to footer_idx (exclusive of footer)
            # But we need to keep the closing </section> of the previous section? 
            # No, footer follows audit section immediately.
            # actually there's a </section> before footer.
            
            # Let's just use the regex, it should work if I copy-pasted correctly.
            pass

# Add js/core.js before </body>
if 'js/core.js' not in new_content:
    new_content = new_content.replace('</body>', '<script src="js/core.js" defer></script>\n</body>')

with open('index_restored.html', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Done. Saved to index_restored.html")
