# Munger::Render.to_html(report)
  
module Munger
  module Render
    
    def self.to_html(report, options = {})
      Html::new(report, options).render
    end
    
    def self.to_text(report)
      Text::new(report).render
    end
    
  end
end
