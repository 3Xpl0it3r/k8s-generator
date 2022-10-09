# k8s-crd-bootstrap
used to bootstrap a empty k8s controller project for crd

# PROJECT LAYOUT

![example](./images/0x03-example.jpg)

# Usage
```bash
➜  TestProject tree -L 3 example-operator -C
example-operator
├── cmd
│   └── operator
│       ├── main.go
│       ├── options
│       ├── signals.go
│       └── start.go
├── e2e
├── go.mod
├── go.sum
├── hack
│   ├── docker
│   │   └── codegen.dockerfile
│   ├── scripts
│   │   └── codegen-update.sh
│   └── tools.go
├── pkg
│   ├── apis
│   │   └── exampleoperator.l0calh0st.cn
│   ├── client
│   │   ├── clientset
│   │   ├── informers
│   │   └── listers
│   ├── controller
│   │   ├── base.go
│   │   ├── doc.go
│   │   ├── event.go
│   │   └── hook.go
│   └── operator
│       └── doc.go
```


