# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dashboard - Home', :js, feature_category: :notifications do
  let_it_be(:user) { create(:user) }

  before do
    stub_feature_flags(personal_homepage: true)
    sign_in user
  end

  describe 'visiting the /dashboard/home route' do
    it 'shows the "Home" menu item as active' do
      visit home_dashboard_path
      expect(page).to have_css("a[data-track-label='homepage_menu'][aria-current='page']")
    end
  end

  describe 'visiting the root route' do
    context 'when using the default homepage ("Projects")' do
      it 'shows the "Projects" menu item as active' do
        visit root_path
        expect(page).to have_css("a[data-track-label='projects_menu'][aria-current='page']")
      end
    end

    context 'when using "Personal homepage" as homepage' do
      let_it_be(:user) { create(:user, dashboard: :homepage) }

      it 'shows the "Home" menu item as active' do
        visit root_path
        expect(page).to have_css("a[data-track-label='homepage_menu'][aria-current='page']")
      end
    end
  end
end
