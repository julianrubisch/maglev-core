# frozen_string_literal: true

module Maglev
  module Content
    class Link < Base
      def href
        link[:href]
      end

      def open_new_window?
        !!link[:open_new_window]
      end

      def to_s
        href
      end

      private

      def link
        @link ||= if @content.is_a?(String)
                    { href: @content, link_type: 'url', open_new_window: false }
                  elsif @content
                    @content
                  else
                    {}
                  end.symbolize_keys
      end
    end
  end
end