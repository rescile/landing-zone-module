// lib/network.rhai

fn parse_cidr_v4(cidr_str) {
    if cidr_str == () {
        throw "Cannot parse undefined/null CIDR";
    }

    if type_of(cidr_str) == "array" {
        if cidr_str.is_empty() {
            throw "Cannot parse empty array as CIDR";
        }
        cidr_str = cidr_str[0];
    }

    let parts = cidr_str.split('/');
    if parts.len() != 2 {
        throw `Invalid CIDR format: ${cidr_str}`;
    }

    let ip_str = parts[0];
    let prefix = parse_int(parts[1]);

    if prefix < 0 || prefix > 32 {
        throw `Invalid IPv4 prefix: ${prefix}`;
    }

    let octets = ip_str.split('.');
    if octets.len() != 4 {
        throw `Invalid IPv4 format: ${ip_str}`;
    }

    let ip_num = (parse_int(octets[0]) << 24)
                | (parse_int(octets[1]) << 16)
                | (parse_int(octets[2]) << 8)
                | parse_int(octets[3]);

    return #{
        ip: ip_num,
        prefix: prefix
    };
}

fn format_ip_v4(ip_num) {
    let o1 = (ip_num >> 24) & 255;
    let o2 = (ip_num >> 16) & 255;
    let o3 = (ip_num >> 8) & 255;
    let o4 = ip_num & 255;
    return `${o1}.${o2}.${o3}.${o4}`;
}

// Equivalent to Rust `cidr_split_n_filter`
fn cidr_split_n(value, args) {
    let n = args.n;
    if n == () || n <= 0 {
        throw "Argument 'n' for cidr_split_n must be a positive integer.";
    }

    let parsed = parse_cidr_v4(value);

    // Round up to next power of 2
    let num_subnets = 1;
    let additional_bits = 0;
    while num_subnets < n {
        num_subnets = num_subnets << 1;
        additional_bits += 1;
    }

    let new_prefix = parsed.prefix + additional_bits;
    if new_prefix > 32 {
        throw `Cannot split ${value} into ${n} subnets: prefix /${new_prefix} exceeds /32`;
    }

    // Mask host bits for base network address
    let host_bits = 32 - parsed.prefix;
    let base_net = (parsed.ip >> host_bits) << host_bits;

    let new_subnet_size = 1 << (32 - new_prefix);
    let subnets = [];

    for i in 0..num_subnets {
        let subnet_num = base_net + (i * new_subnet_size);
        subnets.push(`${format_ip_v4(subnet_num)}/${new_prefix}`);
    }

    return subnets;
}

// Create resolver rule
fn any_internal_dns(firewalls, args) {
    for firewall in firewalls {
        if firewall.class != "private" { continue; }
        for rule in firewall.filter {
            if rule.port == 53
            && rule.enable
            && rule.default_action == "allow"
            && rule.function == "ingress" {
                return true;
            }
        }
    }
    false
}
