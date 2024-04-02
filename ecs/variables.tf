variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "task_definitions" {
  type = map(object({
    image: string,
    tag: string,
    env: list(object({
      name: string
      value: string
    }))
  }))
}