# frozen_string_literal: true

module CapybaraExtensions
  # Clicks the first item by class name, even when the item is not unique.
  #
  # Capybara's `click_on` doesn't work if the element we attempt to click is not unique, so we need this little helper.
  # It also can handle an element not being present at all.
  def click_on_first(class_name:, optional: false)
    first_match = all(".#{class_name}").first

    unless first_match
      return if optional

      raise "Couldn't find element to click on with class '#{class_name}'"
    end

    first_match.click
  end
end
