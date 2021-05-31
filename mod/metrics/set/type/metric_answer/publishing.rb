include_set Abstract::Publishable

def unpublished
  if researched_value?
    super
  elsif relationship?
    false
  else
    calculated_unpublished
  end
end

# this answer is calculated
def calculated_unpublished
  dependee_answers.find(&:unpublished).present?
end
