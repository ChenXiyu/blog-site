resource "aws_route53_record" "blog" {
  zone_id = "Z3H74HDMKETNVY"
  name = "blog.94xychen.net"
  type = "CNAME"
  ttl = "300"
  records = ["chenxiyu.github.io"]
}

resource "aws_route53_health_check" "blog" {
  fqdn              = "${aws_route53_record.blog.name}"
  port              = 80
  type              = "HTTPS"
  resource_path     = "/heart_beat"
  failure_threshold = "5"
  request_interval  = "30"
  tags = {
    Name = "${aws_route53_record.blog.name}"
  }
}

