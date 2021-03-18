job "http-echo-dynamic" {
  datacenters = ["dc1"]
  
  group "echo" {
    count = 5
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:latest"
        args = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "Hello and welcom to ${NOMAD_IP_http} running on port ${NOMAD_PORT_http}"
        ]
      }
    }
  }
  resources {
    network {
      mbits = 10
      port "http" {}
    }
  }
}
