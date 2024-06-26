# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project > User views empty wiki', feature_category: :wiki do
  let_it_be(:user) { create(:user) }

  let(:wiki) { create(:project_wiki, project: project) }

  it_behaves_like 'User views empty wiki' do
    context 'when project is public' do
      let(:project) { create(:project, :public) }

      it_behaves_like 'empty wiki message', writable: false

      context 'and user is logged in' do
        before do
          sign_in(user)
        end

        context 'and user is not a member' do
          it_behaves_like 'empty wiki message', writable: false
        end

        context 'and user is a member' do
          before do
            project.add_developer(user)
          end

          it_behaves_like 'empty wiki message', writable: true
        end
      end
    end

    context 'when project is private' do
      let(:project) { create(:project, :private) }

      it_behaves_like 'wiki is not found'

      context 'and user is logged in' do
        before do
          sign_in(user)
        end

        context 'and user is not a member' do
          it_behaves_like 'wiki is not found'
        end

        context 'and user is a member' do
          before do
            project.add_developer(user)
          end

          it_behaves_like 'empty wiki message', writable: true
        end

        context 'and user is a maintainer' do
          before do
            project.add_maintainer(user)
          end

          it_behaves_like 'empty wiki message', writable: true, confluence: true

          context 'and Confluence is already enabled' do
            before do
              create(:confluence_integration, project: project)
            end

            it_behaves_like 'empty wiki message', writable: true, confluence: false
          end
        end
      end
    end
  end
end
