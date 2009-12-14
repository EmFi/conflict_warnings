class ConflictWarningJavascriptGenerator < Rails::Generator::Base
  def manifest
    record do |m| 
      m.directory 'public/javascripts'
      m.file 'conflict_warning.js', 'public/javascripts/conflict_warnings.js'
    end
  end
end
