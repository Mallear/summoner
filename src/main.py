from dockerwrapper import Docker

wrapper = Docker()

if __name__ == "__main__":
    wrapper.create_container("jwilder/nginx-proxy")
    wrapper.container_list()

