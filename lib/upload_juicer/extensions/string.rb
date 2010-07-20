class String
  # Backward compatibility for Rails 2.x
  unless self.method_defined? :html_safe
    def html_safe
      self
    end
  end
end