require 'json'
require_relative '../../models/course'
require_relative '../../app/exceptions/incompatible_request_exception'

class CourseFromJson
  CODE_KEY = 'codigo'.freeze
  SUBJECT_NAME_KEY = 'materia'.freeze
  TEACHER_KEY = 'docente'.freeze
  QUOTA_KEY = 'cupo'.freeze
  MODALITY_KEY = 'modalidad'.freeze
  PROJECTOR_KEY = 'proyector'.freeze
  LAB_KEY = 'laboratiorio'.freeze
  KEYS = [CODE_KEY, SUBJECT_NAME_KEY, TEACHER_KEY, QUOTA_KEY,
          MODALITY_KEY, PROJECTOR_KEY, LAB_KEY].freeze

  def self.parse(json)
    input = JSON.parse(json)

    args = { code: input[CODE_KEY].to_i,
             subject: input[SUBJECT_NAME_KEY],
             teacher: input[TEACHER_KEY],
             quota: input[QUOTA_KEY],
             modality: input[MODALITY_KEY],
             projector: input[PROJECTOR_KEY],
             laboratory: input[LAB_KEY] }

    course = Course.new(args)
    raise IncompatibleRequestException if course.invalid?

    course
  end
end
