# UI Fix Tasks

## Progress
- [ ] 1. **Match show/edit styles, lighter background** — `components.css`
- [ ] 2. **Textarea borderless, no margin/padding** — `components.css`
- [ ] 3. **Fixed textarea height, no resize** — `components.css`
- [ ] 4. **Body font +4px** — `components.css`
- [ ] 5. **Container height -20px, only text** — `components.css` + `_page_body.html.erb`
- [ ] 6. **Save/Cancel under container** — `_page_body.html.erb` + `inline_edit_controller.js`
- [ ] 7. **Logout near Home** — `_header.html.erb`
- [ ] 8. **Flash auto-dismiss 3s, slide-right** — `flash_controller.js` (new) + `html.css` + `_flash_message.html.erb`
- [ ] 9. **Remove scrollbar from page body** — `components.css`
- [ ] Run tests & rubocop
- [ ] Commit & push

## Files to modify
- `app/assets/stylesheets/variables/components.css`
- `app/views/shared/partials/_page_body.html.erb`
- `app/javascript/controllers/inline_edit_controller.js`
- `app/views/layouts/partials/_header.html.erb`
- `app/views/layouts/partials/_flash_message.html.erb`
- `app/assets/stylesheets/html.css`

## Files to create
- `app/javascript/controllers/flash_controller.js`
