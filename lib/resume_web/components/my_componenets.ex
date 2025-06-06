defmodule ResumeWeb.MyComponenets do
  use Phoenix.Component
  use Gettext, backend: ResumeWeb.Gettext

  # Questionable to include routes for components
  # but since these are our own components I think 
  # it is justified.
  use Phoenix.VerifiedRoutes,
    endpoint: ResumeWeb.Endpoint,
    router: ResumeWeb.Router,
    statics: ResumeWeb.static_paths()

  attr :posts, :list, required: true
  attr :title, :string, default: nil

  def post_list(assigns) do
    ~H"""
    <div>
      <h1 class="text-4xl font-bold mb-4">{if @title, do: @title, else: "Posts"}</h1>
      <div class="flex flex-col">
        <.post_list_entry :for={post <- @posts} post={post} />
      </div>
    </div>
    """
  end

  attr :post, :map, required: true

  def post_list_entry(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-sm hover:shadow-lg transition-shadow duration-200 mb-4 lg:max-w-3xl lg:min-w-3xl md:max-w-2xl sm:max-w-xl">
      <div class="card-body">
        <div class="flex justify-between items-center gap-4">
          <h2 class="card-title text-primary">
            <.link navigate={~p"/posts/#{@post.id}"}>
              {@post.title}
            </.link>
          </h2>

          <span class="text-sm text-base-content/70">
            {Calendar.strftime(@post.date, "%B %d, %Y")}
          </span>
        </div>
        <p class="text-base-content/80 mt-2 line-clamp-2 text-wrap">
          {@post.summary}
        </p>
      </div>
    </div>
    """
  end

  attr :technology, Resume.Technologies.Technology, required: true
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit button will be disabled"
  attr :dom_id, :any, default: nil, doc: "will set the id attribute.  useful for streams"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def technology_row(assigns) do
    ~H"""
    <tr id={@dom_id}>
      <td>{@technology.name}</td>
      <td>{@technology.description}</td>
      <th>
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="btn btn-xs btn-ghost btn-secondary"
            phx-value-technologyid={@technology.id}
            phx-click={@delete_action}
            phx-target={@target}
          >
            Delete
          </button>
          <button
            :if={!@disable_edit}
            class="btn btn-ghost btn-xs btn-primary"
            phx-click={@edit_action}
            phx-value-technologyid={@technology.id}
            phx-target={@target}
          >
            Edit
          </button>
          <button
            :if={@disable_edit}
            class="btn btn-xs btn-ghost btn-warning"
            phx-value-technologyid={@technology.id}
            phx-target={@target}
          >
            Disabled
          </button>
        </div>
      </th>
    </tr>
    """
  end

  attr :technologies, :any, required: true, doc: "A stream of technolgoies"
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit buttons will be disabled"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def technology_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <th>Name</th>
          <th>Description</th>
          <th></th>
        </thead>
        <tbody phx-update="stream" id="tech-table">
          <.technology_row
            :for={{dom_id, technology} <- @technologies}
            technology={technology}
            delete_action={@delete_action}
            edit_action={@edit_action}
            target={@target}
            disable_edit={@disable_edit}
            dom_id={dom_id}
          />
        </tbody>
      </table>
    </div>
    """
  end

  attr :skill, Resume.Skills.Skill, required: true
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit button will be disabled"
  attr :dom_id, :any, default: nil, doc: "A value for the id attribute, useful for streams"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def skill_row(assigns) do
    ~H"""
    <tr id={@dom_id}>
      <td>{@skill.name}</td>
      <td>{@skill.description}</td>
      <th>
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="btn btn-xs btn-ghost btn-secondary"
            phx-value-skillid={@skill.id}
            phx-click={@delete_action}
            phx-target={@target}
          >
            Delete
          </button>
          <button
            :if={!@disable_edit}
            class="btn btn-ghost btn-xs btn-primary"
            phx-click={@edit_action}
            phx-value-skillid={@skill.id}
            phx-target={@target}
          >
            Edit
          </button>
          <button
            :if={@disable_edit}
            class="btn btn-xs btn-ghost btn-warning"
            phx-value-skillid={@skill.id}
            phx-target={@target}
          >
            Disabled
          </button>
        </div>
      </th>
    </tr>
    """
  end

  attr :skills, :any, required: true, doc: "A stream of skills"
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit buttons will be disabled"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def skill_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <th>Name</th>
          <th>Description</th>
          <th></th>
        </thead>
        <tbody phx-update="stream" id="skill-table">
          <.skill_row
            :for={{dom_id, skill} <- @skills}
            skill={skill}
            delete_action={@delete_action}
            edit_action={@edit_action}
            target={@target}
            disable_edit={@disable_edit}
            dom_id={dom_id}
          />
        </tbody>
      </table>
    </div>
    """
  end

  attr :certification, Resume.Certifications.Certification, required: true
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit button will be disabled"
  attr :dom_id, :any, default: nil, doc: "A value for the id attribute, useful for streams"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def certification_row(assigns) do
    ~H"""
    <tr id={@dom_id}>
      <td>{@certification.name}</td>
      <td>{@certification.description}</td>

      <th>
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="btn btn-xs btn-ghost btn-secondary"
            phx-value-certificationid={@certification.id}
            phx-click={@delete_action}
            phx-target={@target}
          >
            Delete
          </button>
          <button
            :if={!@disable_edit}
            class="btn btn-ghost btn-xs btn-primary"
            phx-click={@edit_action}
            phx-value-certificationid={@certification.id}
            phx-target={@target}
          >
            Edit
          </button>
          <button
            :if={@disable_edit}
            class="btn btn-xs btn-ghost btn-warning"
            phx-value-certificationid={@certification.id}
            phx-target={@target}
          >
            Disabled
          </button>
        </div>
      </th>
    </tr>
    """
  end

  attr :certifications, :any, required: true, doc: "A stream of skills"
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit buttons will be disabled"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def certification_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <th>Name</th>
          <th>Description</th>
          <th></th>
        </thead>
        <tbody phx-update="stream" id="certification-table">
          <.certification_row
            :for={{dom_id, cert} <- @certifications}
            certification={cert}
            delete_action={@delete_action}
            edit_action={@edit_action}
            target={@target}
            disable_edit={@disable_edit}
            dom_id={dom_id}
          />
        </tbody>
      </table>
    </div>
    """
  end

  attr :educations, :any, required: true, doc: "A stream of educations"
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit buttons will be disabled"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def education_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <th>Institution</th>
          <th>Institution Type</th>
          <th>Diploma</th>
          <th></th>
        </thead>
        <tbody phx-update="stream" id="education-table">
          <.education_row
            :for={{dom_id, edu} <- @educations}
            education={edu}
            delete_action={@delete_action}
            edit_action={@edit_action}
            target={@target}
            disable_edit={@disable_edit}
            dom_id={dom_id}
          />
        </tbody>
      </table>
    </div>
    """
  end

  attr :education, Resume.Educations.Education, required: true
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit button will be disabled"
  attr :dom_id, :any, default: nil, doc: "A value for the id attribute, useful for streams"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def education_row(assigns) do
    ~H"""
    <tr id={@dom_id}>
      <td>{@education.institution}</td>
      <td>{@education.institution_type}</td>
      <td>{@education.diploma_earned}</td>
      <th>
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="btn btn-xs btn-ghost btn-secondary"
            phx-value-educationid={@education.id}
            phx-click={@delete_action}
            phx-target={@target}
          >
            Delete
          </button>
          <button
            :if={!@disable_edit}
            class="btn btn-ghost btn-xs btn-primary"
            phx-click={@edit_action}
            phx-value-educationid={@education.id}
            phx-target={@target}
          >
            Edit
          </button>
          <button
            :if={@disable_edit}
            class="btn btn-xs btn-ghost btn-warning"
            phx-value-educationid={@education.id}
            phx-target={@target}
          >
            Disabled
          </button>
        </div>
      </th>
    </tr>
    """
  end

  attr :jobs, :any, required: true, doc: "A stream of jobs"
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit buttons will be disabled"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def job_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <th>Company</th>
          <th>Title</th>
          <th>Start Date</th>
          <th>End Date</th>
          <th>Accomplishments</th>
          <th></th>
        </thead>
        <tbody phx-update="stream" id="job-table">
          <.job_row
            :for={{dom_id, job} <- @jobs}
            job={job}
            delete_action={@delete_action}
            edit_action={@edit_action}
            target={@target}
            disable_edit={@disable_edit}
            dom_id={dom_id}
          />
        </tbody>
      </table>
    </div>
    """
  end

  attr :job, Resume.Jobs.Job, required: true
  attr :delete_action, :string, required: true
  attr :edit_action, :string, required: true
  attr :disable_edit, :boolean, default: false, doc: "If true the edit button will be disabled"
  attr :dom_id, :any, default: nil, doc: "A value for the id attribute, useful for streams"

  attr :target, :any,
    default: nil,
    doc: ~S"""
    The target for the events triggered by the buttons in the component.
    In a live component you will likely want to set to @myself
    """

  def job_row(assigns) do
    ~H"""
    <tr id={@dom_id}>
      <td>{@job.company}</td>
      <td>{@job.title}</td>
      <td>{@job.start_date}</td>
      <td>{@job.end_date}</td>
      <td>{accomps_string(@job, 4)}</td>
      <th>
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="btn btn-xs btn-ghost btn-secondary"
            phx-value-jobid={@job.id}
            phx-click={@delete_action}
            phx-target={@target}
          >
            Delete
          </button>
          <button
            :if={!@disable_edit}
            class="btn btn-ghost btn-xs btn-primary"
            phx-click={@edit_action}
            phx-value-jobid={@job.id}
            phx-target={@target}
          >
            Edit
          </button>
          <button
            :if={@disable_edit}
            class="btn btn-xs btn-ghost btn-warning"
            phx-value-jobid={@job.id}
            phx-target={@target}
          >
            Disabled
          </button>
        </div>
      </th>
    </tr>
    """
  end

  # creats list string with trailing replaced with elipsis
  defp accomps_string(%Resume.Jobs.Job{accomplishments: accomps}, count) when is_list(accomps) do
    elipsis? = length(accomps) >= count

    accomps
    |> Enum.map(& &1.name)
    |> Enum.take(4)
    |> then(fn
      list when elipsis? ->
        List.insert_at(list, -1, "...")

      list ->
        list
    end)
    |> Enum.join(",")
  end

  defp accomps_string(_, _), do: ""
end
