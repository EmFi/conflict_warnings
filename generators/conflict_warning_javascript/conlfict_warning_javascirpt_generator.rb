class ConflictWarningJavascriptGenerator < Rails::Generation::Base
  def manifest
    record do |m| 
      m.directory 'public/javascripts'
      m.file 'files/conflict_warning.js', 'public/javascripts/conflict_warnings.js'
    end
  end
end
