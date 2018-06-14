resource "aws_key_pair" "aws_key_pair" {
  key_name   = "nexus.web-key-pair"
  public_key = "${file("./ssh/id_rsa.pub")}"
}

resource "aws_instance" "nexus_instance" {
  ami                    = "ami-6408b21b"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public_for_the_time_being.id}"
  key_name               = "${aws_key_pair.aws_key_pair.id}"
  vpc_security_group_ids = ["${aws_security_group.nexus_sg.id}"]

  tags {
    Name = "Nexus"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("./ssh/id_rsa")}"
    }
  }

  provisioner "local-exec" {
    command = "n=0; until [ $n -ge 3 ]; do env ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 60 -i \"${self.public_dns},\" ./ansible/playbook-ami.yml -u ec2-user --private-key=./ssh/id_rsa && break; n=$[$n+1]; sleep 15; done"
  }

  provisioner "file" {
    source = "./ansible"
    destination = "/home/ec2-user"
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("./ssh/id_rsa")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-galaxy install geerlingguy.java",
      "cd ansible && ansible-playbook -i localhost, -c local playbook-nexus.yml"
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("./ssh/id_rsa")}"
    }
  }
}
