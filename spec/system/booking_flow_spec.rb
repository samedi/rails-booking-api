# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Booking flow' do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:samedi] = OmniAuth::AuthHash.new(
      credentials: { access_token: ENV['TEST_ACCESS_TOKEN'] }
    )
  end

  scenario 'Booking an appointment with no structured comments', vcr: { cassette_name: 'system/booking_flow', match_requests_on: %i[method dateless_uri] } do
    visit('/event_categories?institution_id=00JDFP8A3KYME1FA')
    expect(page).to have_content('Select a category')

    click_on('Select "Zweig, Thorsten"')
    expect(page).to have_content('Select a type')

    click_on('Select "Akupunktur"')
    expect(page).to have_content('Select a date')

    click_on('Next month')
    expect(page).to have_content('Select a date')

    click_on_first(class_name: 'calendar-item-link')
    expect(page).to have_content('Select a time')

    click_on_first(class_name: 'timeslot-button')
    expect(page).to have_content('Confirm Your Booking')

    click_on(class: 'confirm-booking-login')
    expect(page).to have_content('Confirm Your Booking')

    click_on('Confirm Booking')
    expect(page).to have_content('Your appointment was successfully booked')
  end

  scenario 'Booking an appointment with structured comments', vcr: { cassette_name: 'system/booking_flow_with_comments', match_requests_on: %i[method dateless_uri] } do
    visit('/event_categories?institution_id=2kqsyve1h4t0dyv5')
    expect(page).to have_content('Select a category')

    click_on('Select "Zahnmedizin"')
    expect(page).to have_content('Select a type')

    click_on('Select "Prophylaxe"')
    expect(page).to have_content('Select a date')

    click_on_first(class_name: 'calendar-item-link')
    expect(page).to have_content('Select a time')

    click_on_first(class_name: 'timeslot-button')
    expect(page).to have_content('Confirm Your Booking')
    expect(page).not_to have_content('Neupatient')
    expect(page).not_to have_content('Vorerkrankungen')

    click_on(class: 'confirm-booking-login')
    expect(page).to have_content('Confirm Your Booking')
    expect(page).to have_content('Neupatient')
    expect(page).to have_content('Vorerkrankungen')
    expect(page).not_to have_content('This field is required and cannot be empty.')

    click_on('Confirm Booking')
    expect(page).to have_content('This field is required and cannot be empty.')

    check('JA')
    fill_in('Vorerkrankungen', with: 'Keine')

    click_on('Confirm Booking')
    expect(page).to have_content('Your appointment was successfully booked')
  end
end
