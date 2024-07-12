
// photoprism docker Image: photoprism/photoprism:latest
// mariadb docker Image: mariadb:11

///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data centers that the job runs in"
  type        = list(string)
}

variable "namespace" {
  description = "namespace that the job runs in"
  type        = string
  default     = "default"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "photoprism"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
  default    = "photoprism/photoprism:latest"
}

variable "docker_image_mariadb" {
  description = "Docker image"
  type        = string
  default = "mariadb:11"
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "host" {
  description = "host constraint for photoprism"
  type        = string
}

variable "mariadb_host" {
  description = "host for mariadb"
  type        = string
}

variable "mariadb_port" {
  description = "port for mariadb"
  type        = number
  default     = 3306
}

variable "mariadb_data" {
  description = "persistent data volume for mariadb"
  type        = string
}

variable "mariadb_database" {
  description = "database name for mariadb"
  type        = string
  default = "photoprism"
}

variable "mariadb_user" {
  description = "database user for mariadb"
  type        = string
  default = "photoprism"
}

variable "mariadb_password" {
  description = "database password for mariadb"
  type        = string
}

variable "mariadb_root_password" {
  description = "root password for mariadb"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "photoprism" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "mariadb" {

    constraint {
      attribute = node.unique.name
      operator  = "="
      value     = var.mariadb_host
    }

    network {
      port "mysql" {
        static = var.mariadb_port
        to     = 3306
      }
    }

    service {
      tags     = [ "mysql", "mariadb" ]
      name     = var.service_name
      port     = "mysql"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "mariadb" {
      driver = "docker"

      env {
        MARIADB_AUTO_UPGRADE = "1"
        MARIADB_INITDB_SKIP_TZINFO = "1"
        MARIADB_DATABASE = var.mariadb_database
        MARIADB_USER = var.mariadb_user
        MARIADB_PASSWORD = var.mariadb_password
        MARIADB_ROOT_PASSWORD = var.mariadb_root_password
      }

      config {
        image       = var.docker_image_mariadb
        force_pull  = var.docker_always_pull
        ports       = [ "mysql" ]
        dns_servers = var.service_dns
        volumes = compact([
          var.mariadb_data == "" ? "" : format("%s:/var/lib/mysql", var.mariadb_data)
        ])
      }
    }
  }   // group "mariadb"
}     // job "photoprism"

/*
    environment:
      PHOTOPRISM_ADMIN_USER: "admin"                 # admin login username
      PHOTOPRISM_ADMIN_PASSWORD: "insecure"          # initial admin password (8-72 characters)
      PHOTOPRISM_AUTH_MODE: "password"               # authentication mode (public, password)
      PHOTOPRISM_SITE_URL: "http://localhost:2342/"  # server URL in the format "http(s)://domain.name(:port)/(path)"
      PHOTOPRISM_DISABLE_TLS: "false"                # disables HTTPS/TLS even if the site URL starts with https:// and a certificate is available
      PHOTOPRISM_DEFAULT_TLS: "true"                 # defaults to a self-signed HTTPS/TLS certificate if no other certificate is available
      PHOTOPRISM_ORIGINALS_LIMIT: 5000               # file size limit for originals in MB (increase for high-res video)
      PHOTOPRISM_HTTP_COMPRESSION: "gzip"            # improves transfer speed and bandwidth utilization (none or gzip)
      PHOTOPRISM_LOG_LEVEL: "info"                   # log level: trace, debug, info, warning, error, fatal, or panic
      PHOTOPRISM_READONLY: "false"                   # do not modify originals directory (reduced functionality)
      PHOTOPRISM_EXPERIMENTAL: "false"               # enables experimental features
      PHOTOPRISM_DISABLE_CHOWN: "false"              # disables updating storage permissions via chmod and chown on startup
      PHOTOPRISM_DISABLE_WEBDAV: "false"             # disables built-in WebDAV server
      PHOTOPRISM_DISABLE_SETTINGS: "false"           # disables settings UI and API
      PHOTOPRISM_DISABLE_TENSORFLOW: "false"         # disables all features depending on TensorFlow
      PHOTOPRISM_DISABLE_FACES: "false"              # disables face detection and recognition (requires TensorFlow)
      PHOTOPRISM_DISABLE_CLASSIFICATION: "false"     # disables image classification (requires TensorFlow)
      PHOTOPRISM_DISABLE_RAW: "false"                # disables indexing and conversion of RAW images
      PHOTOPRISM_RAW_PRESETS: "false"                # enables applying user presets when converting RAW images (reduces performance)
      PHOTOPRISM_SIDECAR_YAML: "true"                # creates YAML sidecar files to back up picture metadata
      PHOTOPRISM_BACKUP_ALBUMS: "true"               # creates YAML files to back up album metadata
      PHOTOPRISM_BACKUP_DATABASE: "true"             # creates regular backups based on the configured schedule
      PHOTOPRISM_BACKUP_SCHEDULE: "daily"            # backup SCHEDULE in cron format (e.g. "0 12 * * *" for daily at noon) or at a random time (daily, weekly)
      PHOTOPRISM_INDEX_SCHEDULE: ""                  # indexing SCHEDULE in cron format (e.g. "@every 3h" for every 3 hours; "" to disable)
      PHOTOPRISM_AUTO_INDEX: 300                     # delay before automatically indexing files in SECONDS when uploading via WebDAV (-1 to disable)
      PHOTOPRISM_AUTO_IMPORT: -1                     # delay before automatically importing files in SECONDS when uploading via WebDAV (-1 to disable)
      PHOTOPRISM_DETECT_NSFW: "false"                # automatically flags photos as private that MAY be offensive (requires TensorFlow)
      PHOTOPRISM_UPLOAD_NSFW: "true"                 # allows uploads that MAY be offensive (no effect without TensorFlow)
      PHOTOPRISM_DATABASE_DRIVER: "mysql"            # MariaDB 10.5.12+ (MySQL successor) offers significantly better performance compared to SQLite
      PHOTOPRISM_DATABASE_SERVER: "mariadb:3306"     # MariaDB database server (hostname:port)
      PHOTOPRISM_DATABASE_NAME: "photoprism"         # MariaDB database schema name
      PHOTOPRISM_DATABASE_USER: "photoprism"         # MariaDB database user name
      PHOTOPRISM_DATABASE_PASSWORD: "insecure"       # MariaDB database user password
      PHOTOPRISM_SITE_CAPTION: "AI-Powered Photos App"
      PHOTOPRISM_SITE_DESCRIPTION: ""                # meta site description
      PHOTOPRISM_SITE_AUTHOR: ""                     # meta site author
      ## Video Transcoding (https://docs.photoprism.app/getting-started/advanced/transcoding/):
      # PHOTOPRISM_FFMPEG_ENCODER: "software"        # H.264/AVC encoder (software, intel, nvidia, apple, raspberry, or vaapi)
      # PHOTOPRISM_FFMPEG_SIZE: "1920"               # video size limit in pixels (720-7680) (default: 3840)
      # PHOTOPRISM_FFMPEG_BITRATE: "32"              # video bitrate limit in Mbit/s (default: 50)
      ## Run/install on first startup (options: update https gpu ffmpeg tensorflow davfs clitools clean):
      # PHOTOPRISM_INIT: "https gpu tensorflow"
    ## Storage Folders: "~" is a shortcut for your home directory, "." for the current directory
    volumes:
      # "/host/folder:/photoprism/folder"                # Example
      # - "/example/family:/photoprism/originals/family" # *Additional* media folders can be mounted like this
      # - "~/Import:/photoprism/import"                  # *Optional* base folder from which files can be imported to originals
      - "./storage:/photoprism/storage"                  # *Writable* storage folder for cache, database, and sidecar files (DO NOT REMOVE)
*/