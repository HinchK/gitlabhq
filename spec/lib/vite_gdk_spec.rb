# frozen_string_literal: true

require 'spec_helper'

VITE_GDK_CONFIG_FILEPATH = "config/vite.gdk.json"

RSpec.describe ViteGdk, feature_category: :tooling do
  before do
    allow(ViteRuby).to receive(:configure)
    allow(ViteRuby.env).to receive(:[]=)
    allow(YAML).to receive(:safe_load_file)
  end

  describe '#load_gdk_vite_config' do
    context 'when not in production environment' do
      before do
        stub_env('RAILS_ENV', nil)
      end

      context 'when it loads file successfully' do
        it 'configures ViteRuby' do
          expect(File).to receive(:exist?) do |file_path|
            expect(file_path).to end_with(VITE_GDK_CONFIG_FILEPATH)
          end.and_return(true)
          expect(YAML).to receive(:safe_load_file) do |file_path|
            expect(file_path).to end_with(VITE_GDK_CONFIG_FILEPATH)
          end.and_return('enabled' => true, 'port' => 3038)
          expect(ViteRuby).to receive(:configure).with(port: 3038)
          expect(ViteRuby.env).to receive(:[]=).with('VITE_ENABLED', 'true')

          described_class.load_gdk_vite_config
        end
      end

      context 'when config file is missing' do
        it 'does nothing' do
          expect(File).to receive(:exist?) do |file_path|
            expect(file_path).to end_with(VITE_GDK_CONFIG_FILEPATH)
          end.and_return(false)
          expect(ViteRuby).not_to receive(:configure)
          expect(ViteRuby.env).not_to receive(:[]=).with('VITE_ENABLED', 'false')
          expect(ViteRuby.env).not_to receive(:[]=).with('VITE_ENABLED', 'true')

          described_class.load_gdk_vite_config
        end
      end
    end

    context 'when in production environment' do
      before do
        stub_env('RAILS_ENV', 'production')
      end

      it 'does not load and configure ViteRuby' do
        expect(YAML).not_to receive(:safe_load_file)
        expect(ViteRuby).not_to receive(:configure)
        expect(ViteRuby.env).not_to receive(:[]=).with('VITE_ENABLED')

        described_class.load_gdk_vite_config
      end
    end
  end
end
