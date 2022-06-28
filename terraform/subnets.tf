resource "aws_subnet" "subnet-1" {
  cidr_block = "${cidrsubnet(aws_vpc.subnet.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.subnet.id}"
  availability_zone = "us-east-2a"
}

resource "aws_route_table" "route-table" {
  vpc_id = "${aws_vpc.subnet.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway-1.id}"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-1.id}"
  route_table_id = "${aws_route_table.route-table.id}"
}