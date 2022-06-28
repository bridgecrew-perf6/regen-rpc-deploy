resource "aws_internet_gateway" "gateway-1" {
  vpc_id = "${aws_vpc.subnet.id}"
}