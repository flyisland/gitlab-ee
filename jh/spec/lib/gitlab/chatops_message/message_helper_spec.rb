# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::MessageHelper do
  subject do
    Class.new do
      include Gitlab::ChatopsMessage::MessageHelper

      def project_url
        "http://gdk.test:3000/aa/bb"
      end
    end.new
  end

  describe '#limit_output' do
    it 'replace image/video tag and add project url in resource link in content' do
      content = "line1\n![image](/uploads/8180/image.png)\n" \
        "line2\n![lovely cat](https://example.com/assets/img/2021/08/11/-s1800-c85.mp4)\n" \
        "line3\n[gitlab.dmg](/uploads/17f017/gitlab.dmg)\n" \
        "line4\n[rails.zip](https://example.com/uploads/17f0/rails.zip)\n" \
        "line5\n[abc.md](./abc.md)\n" \
        "line6\n<img src='example.png'></img>line6\n" \
        "line7\n<img src='example.png'/>line7\n" \
        "line8\n<img src='example.png'>line8\n" \
        "line9\n[abc.md](ftp://abc.com/abc.md)"

      result1 = "line1\n[image](http://gdk.test:3000/aa/bb/uploads/8180/image.png)\n" \
        "line2\n[lovely cat](https://example.com/assets/img/2021/08/11/-s1800-c85.mp4)\n" \
        "line3\n[gitlab.dmg](http://gdk.test:3000/aa/bb/uploads/17f017/gitlab.dmg)\n" \
        "line4\n[rails.zip](https://example.com/uploads/17f0/rails.zip)\n" \
        "line5\n\n" \
        "line6\nline6\n" \
        "line7\nline7\n" \
        "line8\nline8\n" \
        "line9\n"

      expect(subject.limit_output(content)).to eq(result1)
    end

    it 'return limitation message if content is too long' do
      expect(subject.limit_output("a" * 4000)).to eq('Content length exceeds maximum allowed to display.')
    end
  end
end
