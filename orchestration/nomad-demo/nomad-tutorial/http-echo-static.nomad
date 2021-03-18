job "http-echo" {
  datacenters = ["dc1"]

  group "echo" {
    count = 1
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:latest"
        args = [
          "-listen",":8080",
          "-text", "Hello and welcome from Nomad!"
        ]
      }
      resources {
        network {
          mbits = 10
          port "http" {
            static = 8080
          }
        }
      }
    }
  }
}
