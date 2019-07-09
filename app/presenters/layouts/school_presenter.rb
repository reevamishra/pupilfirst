module Layouts
  class SchoolPresenter < ::ApplicationPresenter
    def show_admin_routes?
      current_school_admin.present?
    end

    def coach_profile?
      coach_dashboard_path.present?
    end

    def props
      {
        school_name: current_school.name,
        school_logo_path: school_logo_path,
        school_icon_path: school_icon_path,
        courses: courses_in_school,
        is_student: founder_profile?,
        review_path: coach_dashboard_path
      }
    end

    def founder_profile?
      current_user.founders.joins(:school).where(schools: { id: current_school }).exists?
    end

    def coach_dashboard_path
      @coach_dashboard_path ||= begin
        faculty = current_user.faculty.find_by(school: current_school)

        if faculty.present?
          if faculty.courses.exists?
            view.course_coach_dashboard_path(faculty.courses.first)
          elsif faculty.startups.exists?
            view.course_coach_dashboard_path(faculty.startups.first.course)
          end
        end
      end
    end

    def school_logo_path
      if current_school.logo_on_light_bg.attached?
        view.rails_blob_path(current_school.logo_variant("thumb"), only_path: true)
      else
        view.image_path('shared/pupilfirst-icon.svg')
      end
    end

    def school_icon_path
      if current_school.icon.attached?
        view.rails_blob_path(current_school.icon_variant("thumb"), only_path: true)
      else
        '/favicon.png'
      end
    end

    def nav_link_classes(path)
      default_classes = "global-sidebar__primary-nav-link py-4 px-5"
      view.current_page?(path) ? default_classes + " global-sidebar__primary-nav-link--active" : default_classes
    end

    private

    def courses_in_school
      current_school.courses.as_json(only: %i[name id])
    end
  end
end
