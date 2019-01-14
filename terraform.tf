provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile="default"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.verdaccio.id}"
  instance_id = "${aws_instance.node-verdaccio.id}"
}
resource "aws_ebs_volume" "verdaccio" {
  availability_zone = "us-east-1a"
  size              = 10

   tags {
    Name = "yh-verdaccio-ebs"
  }
}


/*data "aws_ami" "nat_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
*/

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa ENTRY KEYHERE"
}

resource "aws_instance" "node-verdaccio" {
  ami           = "ami-009d6802948d06e52"
  instance_type = "t2.micro"
  key_name = "deployer-key"

  vpc_security_group_ids = [
    "sg-037addfb80d656a6e"
  ]

  provisioner "file" {
    source      = "package.json"
    destination = "~/package.json"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user="ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
    //Aws crenditals
   provisioner "file" {
    source      = "~/.aws/config"
    destination = "~/.aws/config"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user="ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
  provisioner "file" {
    source      = "~/.aws/credentials"
    destination = "~/.aws/credentials"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user="ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "file" {
    source      = "config.yml"
    destination = "~/config.yml"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user="ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "file" {
    source      = "htpasswd"
    destination = "~/htpasswd"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user="ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "sudo yum update -y",
      "curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -",
      "sudo yum -y install nodejs ",
      "npm install",
      "npm run start &",
    ]

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user="ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  tags = {
    Name = "node-verdaccio"
  }
}
