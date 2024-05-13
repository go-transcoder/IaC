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
    image : string,
    repository_name : string,
    family : string,
    env : list(object({
      name : string
      value : string
    }))
    portMapping : optional(list(object({
      containerPort : number
      hostPort : number
    })))
  }))
}

variable "services" {
  type = map(object({
    task_definition : string
    desired_count : number
    deployment_maximum_percent : number
    deployment_minimum_healthy_percent : number
    subnets_list : list(string)
    security_group : string
    load_balancer : optional(set(object({
      target_group_arn : string
      container_port : number
    })))
  }))
  default = {}
}