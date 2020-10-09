#!/bin/bash -e

echo "Installing restalpr"

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20006 restalpr

case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q install --no-install-recommends --no-install-suggests openalpr libopenalpr-data python3 python3-tornado python3-openalpr
        #traineddata is installed in the wrong directory
        cp -R /usr/share/openalpr/runtime_data/ocr/tessdata/*.traineddata /usr/share/openalpr/runtime_data/ocr/
        rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list
    ;;
    centos8)
        exit 1
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

cat <<-'EOF' > /restalpr.py
import openalpr
import json
import tornado.ioloop
import tornado.web
import locale

class MainHandler(tornado.web.RequestHandler):
    def _ko(self, status, message):
        self.set_status(status)
        self.finish(json.dumps([{
            'error': message,
        }]))

    def post(self):
        self.set_header("Content-Type", "application/json")
        if 'image' not in self.request.files:
            self._ko(400, 'Image parameter not provided')
            return
        bytes = self.request.files['image'][0]['body']
        if len(bytes) <= 0:
            self._ko(400, 'Image is empty')
            return
        results = alpr.recognize_array(bytes)
        self.finish(json.dumps(results))

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, 'C')
    print("initializing openalpr")
    alpr = openalpr.Alpr("eu", "/etc/openalpr/openalpr.conf", "/usr/share/openalpr/runtime_data")
    alpr.set_top_n(5)
    alpr.set_default_region('it')
    alpr.set_detect_region(True)
    print("initializing appliction")
    application = tornado.web.Application([
        (r"/", MainHandler),
    ])
    port = 8080
    application.listen(port)
    print("serving on port {0}; test with: curl -vvv -F 'image=@image.jpg' http://localhost:{0}/".format(port))
    try:
        tornado.ioloop.IOLoop.current().start()
    except:
        print("shutting down...")
        tornado.ioloop.IOLoop.instance().stop()
EOF
