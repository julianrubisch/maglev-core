# frozen_string_literal: true

require 'rails_helper'

describe Maglev::PersistSectionScreenshot do
  before { FileUtils.rm_rf(Rails.root.join('public/my-theme')) }

  let(:service) { described_class.new }
  subject { service.call(base64_image: base64_image, screenshot_path: 'my-theme/abcdefg.png') }

  context 'the base64 image is empty' do
    let(:base64_image) { nil }
    it 'returns nil' do
      is_expected.to eq false
    end
  end

  context 'the base64 image is present' do
    let(:base64_image) { 'data:image/png;base64,bodyofthepngfile' }
    it 'persists the PNG in the filesystem' do
      is_expected.to eq true
      expect(File.exist?(Rails.root.join('public/my-theme/abcdefg.png'))).to eq true
    end
  end
end
