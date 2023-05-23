# frozen_string_literal: true

Quand("je me rends sur la page d'accueil") do
  visit "/"
end

Quand("print the page") do
  log page.html
end

Quand("je clique sur {string}") do |label|
  click_on label
end

Alors("la page contient {string}") do |content|
  expect(page).to have_content(content)
end

Alors("le titre de la page contient {string}") do |content|
  expect(page.title).to include content
end

Quand("je remplis {string} avec {string}") do |label, value|
  fill_in label, with: value
end

Quand("je clique sur {string} dans la rangée {string}") do |link, row|
  within("tr", text: row) do
    click_link(link)
  end
end

Alors("je peux voir dans le tableau {string}") do |caption, table|
  expect(page).to have_table(caption, with_rows: table.rows)
end

Alors("debug") do
  debugger # rubocop:disable Lint/Debugger
end
