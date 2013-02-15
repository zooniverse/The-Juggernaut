xml.instruct!
xml.annotations do |annotations|
	@annotations.each do |ann|
		annotations.annotation do |annotation|
			annotation.id ann.id
			annotation.zooniverse_user_id ann.classification.zooniverse_user_id
			annotation.task_id ann.task_id
			annotation.subjects do |subjects|
				ann.classification.subjects.each do |a|
					subjects.subject do |subject|
						subject.id a.id
						subject.location a.location
					end
				end
			end
		end
	end
end