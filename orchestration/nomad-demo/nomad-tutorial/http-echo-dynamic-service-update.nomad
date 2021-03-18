job "http-echo-dynamic-service" {
  datacenters = ["dc1"]
  
  group "echo" {
    count = 5
    update {
      canary = 1
      max_parallel = 5
    }  
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:latest"
        args = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "uPDATE SUCESSFUL!\n\nHello and welcom to ${NOMAD_IP_http} running on port ${NOMAD_PORT_http}"
        ]
      }
      service {
        name = "http-echo"
        port = "http"
        
        tags = [
          "macbook",
          "urlprefix-/http-echo"
        ]
        check {
          type = "http"
          path = "/health"
          interval = "2s"
          timeout = "2s"
        }
      }
      resources {
        network {
          mbits = 10
          port "http" {}
        }
      }
    }
  }
}
