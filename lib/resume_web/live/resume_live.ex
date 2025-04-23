defmodule ResumeWeb.Live.ResumeLive do
  use ResumeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="lg:max-w-6xl md:max-w-3xl sm:max-w-xl px-2 mx-auto">
      <div class="lg:grid lg:grid-cols-3 gap-8">
        <div class="lg:col-span-2">
          <header class="text-left pt-6">
            <h1 class="text-4xl font-bold mb-2 text-base-content">Patrick Struthers</h1>
            <p class="text-base-content">
              Security professional with 10 years of experience in information security. Possesses clear understanding of the connection between business and security needs and the technical and soft skills to satisfy both with an exceptional ability to acquire new skills as needed.
            </p>
          </header>

          <section class="mb-8">
            <h2 class="text-3xl font-bold text-base-content mt-8">Experience</h2>
            <hr />
            <div class="space-y-8">
              <.experience
                title="Information Security Officer"
                company="Catalyst MedTech"
                summary="Led implementation of information security program.  Provided automation and development support to other departments to achieve company goals."
                employ_start="January 2022"
                employ_end="present"
              >
                <.experience_entry
                  slug="Process automation"
                  headline="increased efficiency of IT security and operations using scripting and custom tools"
                  sublines={[
                    "Office 365 scripting using Graph API and enterprise application authentication.",
                    "ETL against various data sources to produce unified reports.",
                    "Scripts to automate network troubleshooting and vulnerability scanning."
                  ]}
                />
                <.experience_entry
                  slug="HITRUST Certification"
                  headline="led a complete redesign of the information security program to achieve HITURST certification.  HITRUST certification has allowed the company to sell to larger clients."
                  sublines={[
                    "Developed security policies and procedures.",
                    "Created and presented information security training to all staff.",
                    "Deployed MFA authentication across the enterprise.",
                    "Implemented an effective security incident response program.",
                    "Deployed a cloud-based centralized monitoring and reporting system."
                  ]}
                />
                <.experience_entry
                  slug="Client communications"
                  headline="served as external point of contact for the Catalyst security department."
                  sublines={[
                    "Led client meetings to create custom deployments to meet client needs.",
                    "Worked with client security teams to provide insight into our security program and facilitate sales.",
                    "Responed to auditors request for information, worked with finance department to achieve SOX compliance."
                  ]}
                />
                <.experience_entry
                  slug="Development of internal tools"
                  headline="developed internal tools to control costs and gather insights from internal data."
                  sublines={[
                    "Analytics tool for combining data from multiple financial platforms using vector search.",
                    "Export and backup of SaaS platforms to facilitate cost savings.",
                    "Reference DICOM server implementation for testing against specifications."
                  ]}
                />
                <.experience_entry
                  slug="ZTNA network deployment"
                  headline="deployed ZTNA solution which improved connectivity and security while reducing support tickets"
                  sublines={[
                    "Identifed TailScale as ZTNA provider, used their documentation to create deployment plan that was used to deploy the solution to endpoints across the country.",
                    "Configured authentication and traffic policies to limit access based on user and endpoint identity."
                  ]}
                />
              </.experience>
              <.experience
                title="Lead Enterprise Engineer"
                company="Infracore"
                summary="Started as a systems administrator on the Enterprise Solutions (ES) team designing and deploying technical solutions to enterprise customers.  After the successful completion of multiple technical projects, I was eventually promoted to lead ES engineer with responsibilities for planning and leading the most complex projects."
                employ_start="2018"
                employ_end="2022"
              >
                <.experience_entry
                  slug="Cloud-native call center deployment"
                  headline="led the deployment for a national medicare regulated pharmacy company resulting in a stable system that improved response times while handling thousands of calls per day."
                />
                <.experience_entry
                  slug="Network security upgrades"
                  headline="architected and deployed network security upgrades resulting in improved performance, reliability, and security for a national medical device manufacturer."
                />
                <.experience_entry
                  slug="Network and infrastructure refresh"
                  headline="redesigned an existing virtualization and network deployment for a biofuels research lab leading to reduced cost and complexity and increased uptime."
                />
                <.experience_entry
                  slug="Migration to Azure"
                  headline="migrated a large existing infrastructure to Azure on a short timeline to realize infrastructure savings."
                />
              </.experience>
              <.experience
                title="System Administrator"
                company="Alvarado Parkway Institute"
                summary="Hired as IT technician and progressed to system administrator role managing a vSphere cluster and the hosted Linux and Windows VMs along with associated storage and networking."
                employ_start="2011"
                employ_end="2018"
              >
                <.experience_entry
                  slug="Network redesign"
                  headline="starting with an existing network serving hundreds of users with frequent downtime deployed new network stack with improved security, performance, and reliability."
                />
                <.experience_entry
                  slug="Wireless network deployment"
                  headline="deployed secure and reliable wireless network to cover hospital campus."
                />
                <.experience_entry
                  slug="Backup solution for hospital data"
                  headline="in response to the threat of ransomware and the requirement to backup patient data, deployed a resilient backup solution including offline backups and automated backup validation and testing."
                />
                <.experience_entry
                  slug="Microsoft endpoint and Active Directory design"
                  headline="leveraged group policies and Microsoft technologies to automate the deployment and configuration of all connected workstation, allowing our IT team of two staff to support over 300 hospital users."
                />
              </.experience>
            </div>
          </section>
        </div>
        <div class="mt-18">
          <.info_box title="Contact">
            <ul class="space-y-1">
              <li>🌐 Website: pjslab.net</li>
              <li>
                📧 Email: <a href="mailto:patrick@pjslab.net" class="link">patrick@pjslab.net</a>
              </li>
              <li>💼 Open to: Full-time positions</li>
              <li>🔧 Specialties: Security, Development</li>
            </ul>
          </.info_box>
          <.info_box title="Skills">
            <.info_list entries={[
              "Incident Management",
              "Functional Programming (Elixir, Javascript)",
              "Network Security, Authentication",
              "Security Log Management and Inspection",
              "Time and Project Management (including Agile)",
              "Strong System Documentation Skills (wiki, Visio, etc.)",
              "Excellent Written and Verbal Communication",
              "Scripting (PowerShell, Python, Batch, Bash)",
              "LLM integration, vector search",
              "SQL (pgsql, msft sql, sqlite)",
              "Network and vulnerability scanning"
            ]} />
          </.info_box>
          <.info_box title="Certifications">
            <.info_list entries={[
              "CISSP",
              "CCSP",
              "HCISSP",
              "Security+",
              "Project Management Professional (PMP)",
              "CCNA Routing and Switching",
              "Azure Certified Administrator",
              "AWS Architect Associate",
              "MCP Windows Server"
            ]} />
          </.info_box>
          <.info_box title="Technologies">
            <p class="text-primary-content break-words">
              Aruba, Fortinet, WireGuard, IPSec, TailScale, Linux, Windows Endpoint/Server, Azure, AWS, Metasploit, nmap, postgres, SQL server, sqlite, PowerShell, bash, JavaScript, HTML, CSS, Elixir, Office 365/Graph API, Azure Log Analytics/KQL
            </p>
          </.info_box>
          <.info_box title="Education">
            <span class="font-bold text-base-content">BA Economics and Minor in Accounting</span>
            <span class="text-primary-content">University of California San Diego</span>
            <span class="text-primary-content">Graduated January 2011</span>
          </.info_box>
        </div>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :title, :string, required: true
  attr :summary, :string, required: true
  attr :company, :string, required: true
  attr :employ_start, :string, required: true
  attr :employ_end, :string, required: true

  def experience(assigns) do
    ~H"""
    <div class="experience-item mt-4  ">
      <h3 class="text-xl font-semibold mb-2 text-base-content">
        {@title}
      </h3>
      <div class="flex justify-between items-baseline">
        <p class="text-lg text-base-content">{@company}</p>
        <span class="text-sm text-primary-content">{@employ_start} - {@employ_end}</span>
      </div>
      <p class="text-primary-content pb-4 pt-2">
        {@summary}
      </p>
      <h4 class="text-lg font-semibold mb-2">Key Contributions</h4>
      <ul class="list-disc pl-5 space-y-2 text-base-content">
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end

  attr :slug, :string, required: true
  attr :headline, :string, required: true
  attr :sublines, :list, default: nil

  def experience_entry(assigns) do
    ~H"""
    <li>
      <span class="font-semibold">{@slug}</span>
      - {@headline}
      <ul :if={@sublines} class="list-[circle] pl-5 space-y-2 text-primary-content">
        <li :for={line <- @sublines}>{line}</li>
      </ul>
    </li>
    """
  end

  attr :entries, :list, required: true

  def info_list(assigns) do
    ~H"""
    <ul class="list-disc space-y-1 pl-4">
      <li :for={entry <- @entries}>{entry}</li>
    </ul>
    """
  end

  attr :title, :string, required: true
  slot :inner_block, required: true

  def info_box(assigns) do
    ~H"""
    <div class="py-3">
      <div class="bg-primary p-4 rounded-lg">
        <h2 class="text-xl font-semibold mb-2 text-primary-content">{@title}</h2>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
