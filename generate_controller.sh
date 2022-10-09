#!/bin/bash
# description: this script is used to build some neceressury files/scripts for init an crd controller
# Copyright 2021 l0calh0st
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#      https://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# PROJECT_NAME is directory of project
PROJECT_NAME=$1
PROJECT_VERSION=$2
PROJECT_AUTHOR=$3

GIT_DOMAIN="github.com"


# exampleoperator.l0calh0st.cn
GROUP_NAME=$(echo ${PROJECT_NAME}|sed 's/-//'|sed 's/_//').${PROJECT_AUTHOR}.cn
# exampleoperator

# CRD type
CRKind=$(echo $(echo ${PROJECT_NAME}|awk -F'-' '{print $1}'|awk -F'_' '{print $1}')|awk '{print toupper(substr($0,1,1))substr($0,2)}')

if [ "${PROJECT_VERSION}" = "" ]
then
    PROJECT_VERSION="v1alpha1"
fi

if [ "${PROJECT_AUTHOR}" = "" ]
then
    PROJECT_AUTHOR="l0calh0st"
fi

# 所有字符串大写
function fn_strings_to_upper(){
    echo $(echo $1|tr '[:lower:]' '[:upper:]')
}
# 所有字符串小写
function fn_strings_to_lower(){
    echo $(echo $1|tr '[:upper:]' '[:lower:]')
}
# 去除特殊符号
function fn_strings_strip_special_charts(){
  echo $(echo ${1}|sed 's/-//'|sed 's/_//')
}

# 首字母大写
function fn_strings_first_upper(){
    str=$1
    firstLetter=`echo ${str:0:1} | awk '{print toupper($0)}'`
    otherLetter=${str:1}
    result=$firstLetter$otherLetter
    echo $result
}

# 生成 go mod 名称
function fn_project_to_gomod(){

    echo "${GIT_DOMAIN}/${PROJECT_AUTHOR}/${PROJECT_NAME}"
}

function fn_group_name() {
    echo $(echo ${PROJECT_NAME}|sed 's/-//'|sed 's/_//').${PROJECT_AUTHOR}.cn
}




####################################################################################################
#  全局 相关的
####################################################################################################

# auto generate regisgter.go file
# 创建group register.go文件 0x00
function fn_gen_gofile_group_register(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    mkdir -pv pkg/apis/${GROUP_NAME}/
    cat >> pkg/apis/${GROUP_NAME}/register.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package $(fn_strings_strip_special_charts ${PROJECT_NAME})

    const (
        GroupName = "${GROUP_NAME}"
    )
EOF
    gofmt -w pkg/apis/${GROUP_NAME}/register.go
}

####################################################################################################
#                            资源类型定义
####################################################################################################
# auto generate doc.go
#
function fn_gen_gofile_group_version_doc(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})     # 项目名称
    GROUP_NAME=$(fn_strings_to_lower ${2})       # Group 名称
    GROUP_VERSION=$(fn_strings_to_lower ${3})    # Group 版本
    mkdir pkg/apis/${GROUP_NAME}/${GROUP_VERSION}
    cat >>pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/doc.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    // +k8s:deepcopy-gen=package
    // +groupName=${GROUP_NAME}

    // Package ${GROUP_VERSION} is the ${GROUP_VERSION} version of the API.
    package ${GROUP_VERSION} // import "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/${GROUP_NAME}/${GROUP_VERSION}"
EOF
    gofmt -w pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/doc.go
}

# auto geneate types.go
function fn_gen_gofile_group_version_types(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})   # 项目名称
    GROUP_NAME=$(fn_strings_to_lower ${2})     # Group 名 称
    GROUP_VERSION=$(fn_strings_to_lower ${3})  # Group 版本
    RESOURCE_KIND=$(fn_strings_to_lower ${4})  # 资源类型
    CRKind=$(fn_strings_first_upper ${RESOURCE_KIND})    #CRKind 名称，首字母要大写
    mkdir pkg/apis/${GROUP_NAME}/${GROUP_VERSION}
    cat >> pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/types.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package ${GROUP_VERSION}

    import (
        metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    )

    // +genclient
    // +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
    // +k8s:defaulter-gen=true

    // ${CRKind} defines ${CRKind} deployment
    type ${CRKind} struct {
        metav1.TypeMeta \`json:",inline"\`
        metav1.ObjectMeta \`json:"metadata,omitempty"\`

        Spec ${CRKind}Spec \`json:"spec"\`
        Status ${CRKind}Status \`json:"status"\`
    }


    // ${CRKind}Spec describes the specification of ${CRKind} applications using kubernetes as a cluster manager
    type ${CRKind}Spec struct {
        // TODO, write your code
    }

    // ${CRKind}Status describes the current status of ${CRKind} applications
    type ${CRKind}Status struct {
        // TODO, write your code
    }

    // +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

    // ${CRKind}List carries a list of ${CRKind} objects
    type ${CRKind}List struct {
        metav1.TypeMeta \`json:",inline"\`
        metav1.ListMeta \`json:"metadata,omitempty"\`

        Items []$CRKind \`json:"items"\`
    }
EOF
    gofmt -w pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/types.go
}

# generate regiser.go
function fn_gen_gofile_group_version_register(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    GROUP_VERSION=$(fn_strings_to_lower ${3})
    RESOURCE_KIND=$(fn_strings_to_lower ${4})  # 资源类型
    CRKind=$(fn_strings_first_upper ${RESOURCE_KIND})    #CRKind 名称，首字母要大写
    mkdir -pv pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/
    cat >> pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/register.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package ${GROUP_VERSION}

    import (
        "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/${GROUP_NAME}"

      metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
      "k8s.io/apimachinery/pkg/runtime"
      "k8s.io/apimachinery/pkg/runtime/schema"
    )

    const (
        Version = "${PROJECT_VERSION}"
    )

    var (
        // SchemeBuilder initializes a scheme builder
      SchemeBuilder = runtime.NewSchemeBuilder(addKnowTypes)
        // AddToScheme is a global function that registers this API group & version to a scheme
      AddToScheme = SchemeBuilder.AddToScheme
    )

    var (
        // SchemeGroupPROJECT_VERSION is group version used to register these objects
      SchemeGroupVersion = schema.GroupVersion{Group:  $(fn_strings_strip_special_charts ${PROJECT_NAME}).GroupName, Version: Version}
    )

    // Resource takes an unqualified resource and returns a Group-qualified GroupResource.
    func Resource(resource string)schema.GroupResource{
      return SchemeGroupVersion.WithResource(resource).GroupResource()
    }

    // Kind takes an unqualified kind and returns back a Group qualified GroupKind
    func Kind(kind string)schema.GroupKind{
      return SchemeGroupVersion.WithKind(kind).GroupKind()
    }

    // addKnownTypes adds the set of types defined in this package to the supplied scheme.
    func addKnowTypes(scheme *runtime.Scheme)error{
      scheme.AddKnownTypes(SchemeGroupVersion,
        new(${CRKind}),
        new(${CRKind}List),)
      metav1.AddToGroupVersion(scheme, SchemeGroupVersion)
      return nil
    }
EOF
    gofmt -w pkg/apis/${GROUP_NAME}/${GROUP_VERSION}/register.go
}
# install
function fn_gen_gofile_install_install(){
      PROJECT_NAME=$(fn_strings_to_lower ${1})     # 项目名称
      GROUP_NAME=$(fn_strings_to_lower ${2})       # Group 名称
      GROUP_VERSION=$(fn_strings_to_lower ${3})    # Group 版本
      mkdir -pv pkg/apis/install
      cat >> pkg/apis/install/install.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
      package install
      import (
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/${GROUP_NAME}/${GROUP_VERSION}"
      "k8s.io/apimachinery/pkg/runtime"
      utilruntime "k8s.io/apimachinery/pkg/util/runtime"
       )

    func Install(scheme *runtime.Scheme){
      utilruntime.Must(${GROUP_VERSION}.AddToScheme(scheme))
    }
EOF
    gofmt -w pkg/apis/install/install.go
}


##############################################################################
#                        CMD相关的部分                               #
##############################################################################
# generate some helper code

# generate main code

function fn_gen_gofile_cmd_project_main() {
    PROJECT_NAME=$(fn_strings_to_lower $1)
    mkdir -pv cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options
    cat >> cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/main.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package main

    import (
      "flag"
      "k8s.io/component-base/logs"
    )

    func main() {
      logs.InitLogs()
      defer logs.FlushLogs()

      cmd := NewStartCommand(SetupSignalHandler())
      cmd.Flags().AddGoFlagSet(flag.CommandLine)
      if err := cmd.Execute();err != nil{
        panic(err)
      }
    }
EOF
    gofmt -w cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))
}

function fn_gen_gofile_cmd_projct_signals() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    mkdir -pv cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/
    cat >> cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/signals.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package main

    import (
      "os"
      "os/signal"
      "syscall"
    )

    var (
      onlyOneSignalHandler = make(chan struct{})
      shutdownSignals      = []os.Signal{os.Interrupt, syscall.SIGTERM}
    )

    // SetupSignalHandler registered for SIGTERM and SIGINT. A stop channel is returned
    // which is closed on one of these signals. If a second signal is caught, the program
    // is terminated with exit code 1.
    func SetupSignalHandler() (signalCh <-chan struct{}) {
      close(onlyOneSignalHandler) // panics when called twice

      stop := make(chan struct{})
      c := make(chan os.Signal, 2)
      signal.Notify(c, shutdownSignals...)
      go func() {
        <-c
        close(stop)
        <-c
        os.Exit(1) // second signal. Exit directly.
      }()

      return stop
    }
EOF
    gofmt -w cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/signals.go
}

function fn_gen_gofile_cmd_project_startcmd() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    GROUP_VERSION=$(fn_strings_to_lower ${3})
    mkdir -pv cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/

    cat >> cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/start.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
    package main
    import (
      "context"
      "flag"
      "fmt"
      "$(fn_project_to_gomod ${PROJECT_NAME})/cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options"
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/install"
      crclientset "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/clientset/versioned"
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/clientset/versioned/scheme"
      crinformers "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/informers/externalversions"
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/controller"
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/crd"
      "github.com/prometheus/client_golang/prometheus"
      "github.com/prometheus/client_golang/prometheus/promhttp"
      "github.com/spf13/cobra"
      apicorev1 "k8s.io/api/core/v1"
      v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
      "k8s.io/client-go/informers"
      "k8s.io/client-go/kubernetes"
      "k8s.io/client-go/rest"
      "k8s.io/client-go/tools/clientcmd"
	  extensionsclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
      cliflag "k8s.io/component-base/cli/flag"
      "k8s.io/component-base/term"
      "k8s.io/klog/v2"
      "net"
      "net/http"
      "os"
      "time"
    )

    func NewStartCommand(signalCh <-chan struct{}) *cobra.Command {
      opts := options.NewOptions()
      cmd := &cobra.Command{
        Short: "Launch ${PROJECT_NAME}",
        Long:  "Launch ${PROJECT_NAME}",
        RunE: func(cmd *cobra.Command, args []string) error {
          if err := opts.Validate(); err != nil {
            return fmt.Errorf("Options validate failed, %v. ", err)
          }
          if err := opts.Complete(); err != nil {
            return fmt.Errorf("Options Complete failed %v. ", err)
          }
          if err := runCommand(opts, signalCh); err != nil {
            return fmt.Errorf("Run %s failed. ", os.Args[0])
          }
          return nil
        },
      }
      fs := cmd.Flags()
      nfs := opts.NamedFlagSets()
      for _, f := range nfs.FlagSets {
        fs.AddFlagSet(f)
      }
      local := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
      klog.InitFlags(local)
      nfs.FlagSet("logging").AddGoFlagSet(local)

      usageFmt := "Usage:\n  %s\n"
      cols, _, _ := term.TerminalSize(cmd.OutOrStdout())
      cmd.SetUsageFunc(func(cmd *cobra.Command) error {
        _, _ = fmt.Fprintf(cmd.OutOrStderr(), usageFmt, cmd.UseLine())
        cliflag.PrintSections(cmd.OutOrStderr(), nfs, cols)
        return nil
      })
      cmd.SetHelpFunc(func(cmd *cobra.Command, args []string) {
        _, _ = fmt.Fprintf(cmd.OutOrStdout(), "%s\n\n"+usageFmt, cmd.Long, cmd.UseLine())
        cliflag.PrintSections(cmd.OutOrStdout(), nfs, cols)
      })
      return cmd
    }

    func runCommand(o *options.Options, signalCh <-chan struct{}) error {
      install.Install(scheme.Scheme)

      var err error
      var stopCh = make(chan struct{})
      restConfig, err := buildKubeConfig("", "")
      if err != nil {
        return err
      }
      // register crd automatically
      extClientSet, err := extensionsclientset.NewForConfig(restConfig); 
      if err != nil {
          return err
      }
      if err := crd.InstallCustomResourceDefineToApiServer(extClientSet); err != nil {
          return err
      }
      defer crd.UnInstallCustomResourceDefineToApiServer(extClientSet)
      kubeClientSet, err := kubernetes.NewForConfig(restConfig)
      if err != nil {
        return err
      }
      crClientSet, err := crclientset.NewForConfig(restConfig)
      if err != nil {
        return err
      }
      crInformers := buildCustomResourceInformerFactory(crClientSet)
      kubeInformers := buildKubeStandardResourceInformerFactory(kubeClientSet)

	  register := prometheus.NewRegistry()
      mux := http.NewServeMux()
      mux.Handle("/metrics", promhttp.HandlerFor(nil, promhttp.HandlerOpts{}))
      svc := &http.Server{Handler: mux}
      l, err := net.Listen("tcp", o.ListenAddress)
      if err != nil {
          return err
      }

      emptyController := controller.NewEmptyController(register)
      defer emptyController.Stop()

      // when all controller work in correctory way, then start health interface
      if err := serve(svc, l) ;err != nil {
          return err
      }

      // start informers, informar should be start after all informart has created
      crInformers.Start(stopCh)
      kubeInformers.Start(stopCh)

      if err := runController(stopCh, emptyController);err != nil {
          return err
      }
    select {
        case <-signalCh:
            klog.Infof("exited")
            close(stopCh)
        case <- stopCh:
        }
    return nil
    }

    func runController(stopCh <- chan struct{}, controller controller.Controller) error {
        if err := controller.Start(1, stopCh); err != nil {
          return err
        }
        return nil
    }

    func serve(srv *http.Server, listener net.Listener) error {
        //level.Info(logger).Log("msg", "Starting insecure server on "+listener.Addr().String())
        if err := srv.Serve(listener); err != http.ErrServerClosed {
          return err
        }
        return nil
    }

    func serveTLS(srv *http.Server, listener net.Listener) error {
        //level.Info(logger).Log("msg", "Starting secure server on "+listener.Addr().String())
        if err := srv.ServeTLS(listener, "", ""); err != http.ErrServerClosed {
          return err
        }
        return nil
    }

    // buildKubeConfig build rest.Config from the following ways
    // 1: path of kube_config 2: KUBECONFIG environment 3. ~/.kube/config, as kubeconfig may not in $HOMEDIR/.kube/
    func buildKubeConfig(masterUrl, kubeConfig string) (*rest.Config, error) {
      cfgLoadingRules := clientcmd.NewDefaultClientConfigLoadingRules()
      cfgLoadingRules.DefaultClientConfig = &clientcmd.DefaultClientConfig
      cfgLoadingRules.ExplicitPath = kubeConfig
      clientConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(cfgLoadingRules, &clientcmd.ConfigOverrides{})
      config, err := clientConfig.ClientConfig()
      if err != nil {
        return nil, err
      }
      if err = rest.SetKubernetesDefaults(config); err != nil {
        return nil, err
      }
      return config, nil
    }

    // buildCustomResourceInformerFactory build crd informer factory according some options
    func buildCustomResourceInformerFactory(crClient crclientset.Interface) crinformers.SharedInformerFactory {
      var factoryOpts []crinformers.SharedInformerOption
      factoryOpts = append(factoryOpts, crinformers.WithNamespace(apicorev1.NamespaceAll))
      factoryOpts = append(factoryOpts, crinformers.WithTweakListOptions(func(listOptions *v1.ListOptions) {
        // todo
      }))
      return crinformers.NewSharedInformerFactoryWithOptions(crClient, 5*time.Second, factoryOpts...)
    }

    // buildKubeStandardResourceInformerFactory build a kube informer factory according some options
    func buildKubeStandardResourceInformerFactory(kubeClient kubernetes.Interface) informers.SharedInformerFactory {
      var factoryOpts []informers.SharedInformerOption
      factoryOpts = append(factoryOpts, informers.WithNamespace(apicorev1.NamespaceAll))
      //factoryOpts = append(factoryOpts, informers.WithCustomResyncConfig(nil))
      factoryOpts = append(factoryOpts, informers.WithTweakListOptions(func(listOptions *v1.ListOptions) {
        // todo
      }))
      return informers.NewSharedInformerFactoryWithOptions(kubeClient, 5*time.Second, factoryOpts...)
    }
EOF
    gofmt -w cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/start.go
}

function fn_gen_gofile_cmd_project_options_interface() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    # create some relative dirs
    mkdir -pv cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options/
    # generate interface.go file
    cat >> cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options/interface.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package options

    import "github.com/spf13/pflag"

    // all custom options should implement this interfaces
    type options interface {
      Validate()[]error
      Complete()error
      AddFlags(*pflag.FlagSet)
    }
EOF
    gofmt -w cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options/interface.go
}

function fn_gen_gofile_cmd_project_options_options(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    mkdir -pv cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options/
    cat >> cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options/options.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
    
    
    package options
    
    import (
      "github.com/spf13/pflag"
      "k8s.io/component-base/cli/flag"
    )
    
    type Options struct {
        // this is example flags
      ListenAddress string
        // TODO write your flags here
    }
    
    var _ options = new(Options)
    
    // NewOptions create an instance option and return
    func NewOptions()*Options{
        // TODO write your code or change this code here
      return &Options{}
    }
    
    
    // Validate validates options
    func(o *Options)Validate()[]error{
        // TODO write your code here, if you need some validation
      return nil
    }
    
    // Complete fill some default value to options
    func(o *Options)Complete()error{
        // TODO write your code here, you may do some defaulter if neceressary
      return nil
    }
    
    //
    func(o *Options)AddFlags(fs *pflag.FlagSet){
      fs.StringVar(&o.ListenAddress,"web.listen-addr", ":8080", "Address on which to expose metrics and web interfaces")
        // TODO write your code here
    }
    
    
    func(o *Options)NamedFlagSets()(fs flag.NamedFlagSets){
      o.AddFlags(fs.FlagSet("$(fn_strings_to_lower ${PROJECT_NAME})"))
      // other options addFlags
      return
    }
EOF
    gofmt -w cmd/$(fn_strings_to_lower $(fn_strings_strip_special_charts ${PROJECT_NAME}))/options/options.go
}


##############################################################################
#                       Controller相关部分                                 #
##############################################################################

function fn_gen_gofile_pkg_controller_interfaces() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    mkdir -pv pkg/controller
    # CONTROLLER_BASE

        cat >> pkg/controller/controller.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package controller
    import (
      "github.com/prometheus/client_golang/prometheus"
    )

    // Controller is generic interface for custom controller, it defines the basic behaviour of custom controller
    type Controller interface {
      Start(wokers int, stopCh <- chan struct{}) error
      Stop()
      AddHook(hook Hook) error
      RemoveHook(hook Hook) error
    }

    // this is example, you should remove it in product
    type emptyController struct {
    }

    func (e emptyController) Start(workers int, stopCh <- chan struct{}) error {
      return nil
    }
    func (e emptyController) Stop() {
    }
    func (e emptyController) AddHook(hook Hook) error {
      return nil
    }
    func (e emptyController) RemoveHook(hook Hook) error {
      return nil
    }
    func NewEmptyController(reg prometheus.Registerer)Controller{
      return &emptyController{}
    }

EOF
    gofmt -w pkg/controller/controller.go

    cat >> pkg/controller/base.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package controller

    import "errors"

    type Base struct {
      hooks []Hook
    }

    func NewControllerBase()Base{
      return Base{hooks: []Hook{}}
    }

    func(c *Base)GetHooks()[]Hook{
      return c.hooks
    }

    func (c *Base) AddHook(hook Hook) error {
      for _,h := range c.hooks{
        if h == hook{
          return errors.New("Given hook is already installed in the current controller ")
        }
      }
      c.hooks = append(c.hooks)
      return nil
    }

    func (c *Base) RemoveHook(hook Hook) error {
      for i,h := range c.hooks{
        if h == hook{
          c.hooks = append(c.hooks[:i], c.hooks[i+1:]...)
          return nil
        }
      }
      return errors.New("Given hook is not installed in the current controller ")
    }
EOF
    gofmt -w pkg/controller/base.go
    # CONTROLLER_EVENT
    cat >> pkg/controller/event.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package controller

    // EventType represents the type of a Event
    type EventType int

    // All Available Event type
    const (
      EventAdded EventType = iota + 1
      EventUpdated
      EventDeleted
    )

    // Event represent event processed by controller.
    type Event struct {
      Type   EventType
      Object interface{}
    }

    // EventsHook extends \`Hook\` interface.
    type EventsHook interface {
      Hook
      GetEventsChan() <-chan Event
    }

    type eventsHooks struct {
      events chan Event
    }

    func (e *eventsHooks) OnAdd(object interface{}) {
      e.events <- Event{
        Type:   EventAdded,
        Object: object,
      }
    }

    func (e *eventsHooks) OnUpdate(object interface{}) {
      e.events <- Event{
        Type:   EventUpdated,
        Object: object,
      }
    }

    func (e *eventsHooks) OnDelete(object interface{}) {
      e.events <- Event{
        Type:   EventDeleted,
        Object: object,
      }
    }

    func (e *eventsHooks) GetEventsChan() <-chan Event {
      return e.events
    }

    func NewEventsHook(channelSize int) EventsHook {
      return &eventsHooks{events: make(chan Event, channelSize)}
    }
EOF
    gofmt -w pkg/controller/event.go
    # CONTROLLER_HOOK
    cat >> pkg/controller/hook.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package controller

    // Hook is interface for hooks that can be inject into custom controller
    type Hook interface {
      // OnAdd runs after the controller finished processing the addObject
      OnAdd(object interface{})
      // OnUpdate runs after the controller finished processing the updatedObject
      OnUpdate(object interface{})
      // OnDelete run after the controller finished processing the deletedObject
      OnDelete(object interface{})
    }
EOF
    gofmt -w pkg/controller/hook.go
    # CONTROLLER_DOC
    cat >> pkg/controller/doc.go << EOF
    /*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
    */

    package controller

    // all code in controller package is automatic-generate, you shouldn't write code in this package if you know what are doing
    // all business code should be written in operator package

    // 所有controller相关的代码都自动生成的，你不应该修改这个里面的代码(除非你知道你需要做什么).
    // 所有业务相关的代码应该在operator里面
EOF
    gofmt -w pkg/controller/doc.go
}

function fn_gen_package_pkg_controller_CRKind() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    GROUP_VERSION=$(fn_strings_to_lower ${3})
    CRKind=$(fn_strings_first_upper $(fn_strings_to_lower ${4}))
# CONTROLLER_CRKIND
    mkdir -pv pkg/controller/$(fn_strings_to_lower ${CRKind})
    cat >> pkg/controller/$(fn_strings_to_lower ${CRKind})/controller.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package $(fn_strings_to_lower ${CRKind})
        import (
        "fmt"
        "time"
        "github.com/prometheus/client_golang/prometheus"
        apicorev1 "k8s.io/api/core/v1"
        utilruntime "k8s.io/apimachinery/pkg/util/runtime"
        "k8s.io/apimachinery/pkg/util/wait"
        "k8s.io/client-go/informers"
        kubeclientset "k8s.io/client-go/kubernetes"
        "k8s.io/client-go/kubernetes/scheme"
        typedcorev1 "k8s.io/client-go/kubernetes/typed/core/v1"
        listercorev1 "k8s.io/client-go/listers/core/v1"
        "k8s.io/client-go/tools/cache"
        "k8s.io/client-go/tools/record"
        "k8s.io/client-go/util/workqueue"
        "k8s.io/klog/v2"

        crclientset "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/clientset/versioned"
        crinformers "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/informers/externalversions"
        crlister${GROUP_VERSION} "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/listers/$(fn_strings_to_lower ${GROUP_NAME})/$(fn_strings_to_lower ${GROUP_VERSION})"
        crcontroller "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/controller"
        croperator "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/operator"
        $(fn_strings_to_lower ${CRKind})operator "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/operator/$(fn_strings_to_lower ${CRKind})"
        croperator "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/operator"
        crhandler "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/controller/$(fn_strings_to_lower ${CRKind})/handler"

    )

    // controller is implement Controller for ${CRKind} resources
    type controller struct {
      crcontroller.Base
      register      prometheus.Registerer
      kubeClientSet kubeclientset.Interface
      crClientSet   crclientset.Interface
      workqueue         workqueue.RateLimitingInterface
      operator      croperator.Operator
      recorder record.EventRecorder

      serviceLister listercorev1.ServiceLister
      $(fn_strings_to_lower ${CRKind})Lister  crlister${GROUP_VERSION}.${CRKind}Lister
      // TODO add other listers here


      cacheSynced []cache.InformerSynced
    }


    // NewController create a new controller for ${CRKind} resources
    func NewController(kubeClientSet kubeclientset.Interface, kubeInformers informers.SharedInformerFactory, crClientSet crclientset.Interface,
      crInformers crinformers.SharedInformerFactory, reg prometheus.Registerer) crcontroller.Controller {
      eventBroadcaster := record.NewBroadcaster()
      eventBroadcaster.StartLogging(klog.V(2).Infof)
      eventBroadcaster.StartRecordingToSink(&typedcorev1.EventSinkImpl{Interface: kubeClientSet.CoreV1().Events(apicorev1.NamespaceAll)})
      recorder := eventBroadcaster.NewRecorder(scheme.Scheme, apicorev1.EventSource{Component: "${CRKind}-operator"})

      return new${CRKind}Controller(kubeClientSet, kubeInformers, crClientSet, crInformers, recorder, reg)
    }

    // new${CRKind}Controller is really
    func new${CRKind}Controller(kubeClientSet kubeclientset.Interface, kubeInformers informers.SharedInformerFactory, crClientSet crclientset.Interface,
      crInformers crinformers.SharedInformerFactory, recorder record.EventRecorder, reg prometheus.Registerer) *controller {
      c := &controller{
        register:      reg,
        kubeClientSet: kubeClientSet,
        crClientSet:   crClientSet,
        recorder:      recorder,
      }
      c.workqueue = workqueue.NewRateLimitingQueue(workqueue.DefaultControllerRateLimiter())

      $(fn_strings_to_lower ${CRKind})Informer := crInformers.$(fn_strings_first_upper $(fn_strings_strip_special_charts ${PROJECT_NAME}))().$(fn_strings_first_upper ${GROUP_VERSION})().${CRKind}s()
      c.$(fn_strings_to_lower ${CRKind})Lister = $(fn_strings_to_lower ${CRKind})Informer.Lister()
      $(fn_strings_to_lower ${CRKind})Informer.Informer().AddEventHandlerWithResyncPeriod(crhandler.New${CRKind}EventHandler(c.enqueueFunc, c.$(fn_strings_to_lower ${CRKind})Lister), 5*time.Second)

      // TODO add some k8s informer(non crd informer)

      c.cacheSynced = append(c.cacheSynced, $(fn_strings_to_lower ${CRKind})Informer.Informer().HasSynced)

      c.operator = $(fn_strings_to_lower ${CRKind})operator.NewOperator(c.kubeClientSet, c.crClientSet, c.$(fn_strings_to_lower ${CRKind})Lister,  c.recorder,c.register)
      return c
    }

    func (c *controller) Start(workers int, stopCh <- chan struct{}) error {
      // wait for all involved cached to be synced , before processing items from the queue is started
      if !cache.WaitForCacheSync(stopCh,  func() bool {
		for _, hasSyncdFn := range c.cacheSynced{
			if !hasSyncdFn(){
				return false
			}
		}
		return true
	}) {
		return fmt.Errorf("timeout wait for cache to be synced")
	}
      klog.Info("Starting the workers of the $(fn_strings_to_lower ${CRKind}) controllers")
      for i:= 0; i< workers ;i ++{
          go wait.Until(c.runWorker, time.Second, stopCh)
      }
      return nil
    }


    // runWorker for loop
    func (c *controller) runWorker() {
      defer utilruntime.HandleCrash()
      for c.processNextItem() {}
    }

    func (c *controller) processNextItem() bool {
      key, quit := c.workqueue.Get()
      if quit {
        return false
      }
      defer func() {
        c.workqueue.Done(key)
        klog.Infof("Ending processing key: %d", key)
      }()
      klog.Infof("Starting process key: %q", key)
      if err := c.operator.Reconcile(key.(string)); err != nil {
		c.workqueue.AddRateLimited(key)
        // There was a failure so be sure to report it. This method allows for plugable error handling
        // which can be used for things like cluster-monitoring
        utilruntime.HandleError(fmt.Errorf("failed to reconcile $(fn_strings_to_lower ${CRKind}) %q: %v", key, err))
        return true
      }
      // Successfully processed the key or the key was not found so tell the queue to stop tracking history for your key
      // This will reset things like failure counts for per-items rate limiting
      c.workqueue.Forget(key)
      return true
    }

    func (c *controller) Stop() {
      klog.Info("Stopping the $(fn_strings_to_lower ${CRKind}) operator controller")
      c.workqueue.ShutDown()
    }

    func (c *controller) enqueueFunc(obj interface{}) {
      key, err := cache.DeletionHandlingMetaNamespaceKeyFunc(obj)
      if err != nil {
        klog.Errorf("failed to get key for %v: %v", obj, err)
        return
      }
      c.workqueue.AddRateLimited(key)
    }
EOF
    gofmt -w pkg/controller/$(fn_strings_to_lower ${CRKind})/controller.go

    cat >> pkg/controller/$(fn_strings_to_lower ${CRKind})/collector.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
    package $(fn_strings_to_lower ${CRKind})
EOF
    gofmt -w pkg/controller/$(fn_strings_to_lower ${CRKind})/collector.go

    mkdir -pv pkg/controller/$(fn_strings_to_lower ${CRKind})/handler
    cat >> pkg/controller/$(fn_strings_to_lower ${CRKind})/handler/$(fn_strings_to_lower ${CRKind}).go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package handler

    import (
      crlister${GROUP_VERSION} "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/listers/${GROUP_NAME}/${GROUP_VERSION}"
    )

    type $(fn_strings_to_lower ${CRKind})EventHandler struct {
      $(fn_strings_to_lower ${CRKind})Lister crlister${GROUP_VERSION}.${CRKind}Lister
      enqueueFn func(key interface{})
    }

    func (h *$(fn_strings_to_lower ${CRKind})EventHandler) OnAdd(obj interface{}) {
      panic("implement me")
    }

    func (h *$(fn_strings_to_lower ${CRKind})EventHandler) OnUpdate(oldObj, newObj interface{}) {
      panic("implement me")
    }

    func (h *$(fn_strings_to_lower ${CRKind})EventHandler) OnDelete(obj interface{}) {
      panic("implement me")
    }

    func New${CRKind}EventHandler(enqueueFn func(key interface{}), lister crlister${GROUP_VERSION}.${CRKind}Lister)*$(fn_strings_to_lower ${CRKind})EventHandler{
      return &$(fn_strings_to_lower ${CRKind})EventHandler{
        $(fn_strings_to_lower ${CRKind})Lister: lister,
        enqueueFn:    enqueueFn,
      }
    }
EOF
    gofmt -w pkg/controller/$(fn_strings_to_lower ${CRKind})/handler/$(fn_strings_to_lower ${CRKind}).go


    cat >> pkg/controller/$(fn_strings_to_lower ${CRKind})/handler/service.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package handler

    import (
      crlister${GROUP_VERSION} "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/client/listers/${GROUP_NAME}/${GROUP_VERSION}"
        crconfig "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/config"
        apicorev1 "k8s.io/api/core/v1"
        listenercorev1 "k8s.io/client-go/listers/core/v1"
        "k8s.io/client-go/tools/cache"
    )

    // serviceEventHandler represent serviceeventhandler
    type serviceEventHandler struct {
        serviceListener listenercorev1.ServiceLister
        enqueneFn       func(obj interface{})
        $(fn_strings_to_lower ${CRKind})Lister     crlister${GROUP_VERSION}.${CRKind}Lister
    }

    func NewServiceEventHandler(serviceListener listenercorev1.ServiceLister, enqueueFn func(obj interface{}), $(fn_strings_to_lower ${CRKind})Lister crlister${GROUP_VERSION}.${CRKind}Lister) *serviceEventHandler {
        return &serviceEventHandler{
            serviceListener: serviceListener,
            enqueneFn:       enqueueFn,
            $(fn_strings_to_lower ${CRKind})Lister:     $(fn_strings_to_lower ${CRKind})Lister,
        }
    }

    // serviceEventHandler represent serviceeventhandler
    func (serviceeventhandler *serviceEventHandler) OnAdd(obj interface{}) {
        svc, ok := obj.(*apicorev1.Service)
        if !ok {
            return
        }
        serviceeventhandler.enqueue${CRKind}ForServiceUpdate(svc)
    }

    // serviceEventHandler represent serviceeventhandler
    func (serviceeventhandler *serviceEventHandler) OnDelete(obj interface{}) {
        var deletedSvc *apicorev1.Service
        switch obj.(type) {
        case *apicorev1.Service:
            deletedSvc = obj.(*apicorev1.Service)
        case cache.DeletedFinalStateUnknown:
            deletedObj := obj.(cache.DeletedFinalStateUnknown).Obj
            deletedSvc = deletedObj.(*apicorev1.Service)
        default:
            return
        }
        serviceeventhandler.enqueue${CRKind}ForServiceUpdate(deletedSvc)
    }

    // serviceEventHandler represent serviceeventhandler
    func (serviceeventhandler *serviceEventHandler) OnUpdate(oldObj, newObj interface{}) {
        oldSvc, ok := oldObj.(*apicorev1.Service)
        if !ok {
            return
        }
        newSvc, ok := newObj.(*apicorev1.Service)
        if !ok {
            return
        }
        if oldSvc.ResourceVersion == newSvc.ResourceVersion {
            return
        }
        serviceeventhandler.enqueue${CRKind}ForServiceUpdate(newSvc)
    }

    // serviceEventHandler represent serviceeventhandler
    func (serviceeventhandler *serviceEventHandler) enqueue${CRKind}ForServiceUpdate(svc *apicorev1.Service) {
        appName, ok := svc.Labels[crconfig.${CRKind}AppNameLabel]
        if !ok {
            return
        }
        app, err := serviceeventhandler.$(fn_strings_to_lower ${CRKind})Lister.${CRKind}s(svc.GetNamespace()).Get(appName)
        if err != nil {
            return
        }
        serviceeventhandler.enqueneFn(app)
    }
EOF
    gofmt -w pkg/controller/$(fn_strings_to_lower ${CRKind})/handler/service.go


    cat >> pkg/controller/$(fn_strings_to_lower ${CRKind})/informer.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package $(fn_strings_to_lower ${CRKind})
EOF
    gofmt -w pkg/controller/$(fn_strings_to_lower ${CRKind})/informer.go
}


##############################################################################
#                       Operator相关的部分                                  #
##############################################################################

function fn_gen_package_pkg_operator_interfaces(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    mkdir pkg/operator/
    cat >> pkg/operator/operator.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package operator

    // Operator implement reconcile interface, all operator should implement this interface
    type Operator interface {
      Reconcile(obj interface{})error
    }
EOF
    gofmt -w pkg/operator/operator.go



    cat >> pkg/operator/doc.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package operator

    // all business code write in this package
    // all relative operator should implement \`Operator\` interface

    // 所有的业务代码应该写在这个package里面
    // 所有相关的operator都应该实现\`Operator\`代码
EOF
    gofmt -w pkg/operator/doc.go
}

function fn_gen_package_pkg_operator_crdoperator() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    GROUP_VERSION=$(fn_strings_to_lower ${3})
    RESOURCE_KIND=$(fn_strings_to_lower ${4})  # 资源类型
    CRKind=$(fn_strings_first_upper ${RESOURCE_KIND})    #CRKind 名称，首字母要大写

    mkdir -pv  pkg/operator/$(fn_strings_to_lower ${CRKind})

    cat >> pkg/operator/$(fn_strings_to_lower ${CRKind})/operator.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
    package ${RESOURCE_KIND}

    import (
      "fmt"

      "github.com/prometheus/client_golang/prometheus"
      k8serror "k8s.io/apimachinery/pkg/api/errors"
      utilruntime "k8s.io/apimachinery/pkg/util/runtime"
      "k8s.io/client-go/kubernetes"
      "k8s.io/client-go/tools/cache"
      "k8s.io/client-go/tools/record"

      crclientset "$(fn_project_to_gomod)/pkg/client/clientset/versioned"
      crlister${GROUP_VERSION} "$(fn_project_to_gomod)/pkg/client/listers/${GROUP_NAME}/${GROUP_VERSION}"
      croperator "$(fn_project_to_gomod)/pkg/operator"
    )

    type operator struct {
      $(fn_strings_to_lower ${CRKind})Client    crclientset.Interface
      kubeClientSet kubernetes.Interface
      recorder      record.EventRecorder
      $(fn_strings_to_lower ${CRKind})Lister    crlister${GROUP_VERSION}.$(fn_strings_first_upper ${CRKind})Lister
      reg           prometheus.Registerer
    }

    func NewOperator(kubeClientSet kubernetes.Interface, crClient crclientset.Interface, $(fn_strings_to_lower ${CRKind})Lister crlister${GROUP_VERSION}.${CRKind}Lister, recorder record.EventRecorder, reg prometheus.Registerer) croperator.Operator {
      return &operator{
        $(fn_strings_to_lower ${CRKind})Client:    crClient,
        kubeClientSet: kubeClientSet,
        $(fn_strings_to_lower ${CRKind})Lister:    $(fn_strings_to_lower ${CRKind})Lister,
        reg:           reg,
      }
    }

    func (o *operator) Reconcile(object interface{}) error {
      namespace, name, err := cache.SplitMetaNamespaceKey(object.(string))
      if err != nil {
        return err
      }

      $(fn_strings_to_lower ${CRKind}), err := o.$(fn_strings_to_lower ${CRKind})Lister.${CRKind}s(namespace).Get(name)
      if err != nil {
          return err
      }
      _ = $(fn_strings_to_lower ${CRKind})
      // TODO write your code here
      return nil
    }


EOF
    gofmt -w pkg/operator/$(fn_strings_to_lower ${CRKind})/operator.go

    cat >> pkg/operator/$(fn_strings_to_lower ${CRKind})/util.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
    package ${RESOURCE_KIND}

    import (
    crapi${GROUP_VERSION} "$(fn_project_to_gomod)/pkg/apis/${GROUP_NAME}/${GROUP_VERSION}"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    )

    func get$(fn_strings_first_upper ${CRKind})AppName(obj *crapi${GROUP_VERSION}.${CRKind}, target string)string{
        return obj.GetName() + "-" + target
    }


    // getResourceLabels generate labels according crResource object
    func getResourceLabels(obj *crapi${GROUP_VERSION}.${CRKind})map[string]string{
        labels := map[string]string{
            "app": obj.GetName(),
            "controller": obj.Kind,
        }
        return labels
    }

    // getResourceAnnotations generate annotations according crResource object
    func getResourceAnnotations(obj *crapi${GROUP_VERSION}.${CRKind})map[string]string{
        annotations := map[string]string{}
        return annotations
    }

    // getResourceOwnerReference generate OwnerReference according crResource object
    func getResourceOwnerReference(obj *crapi${GROUP_VERSION}.${CRKind})[]metav1.OwnerReference{
        ownerReference := []metav1.OwnerReference{}
        ownerReference = append(ownerReference, *metav1.NewControllerRef(obj, crapi${GROUP_VERSION}.SchemeGroupVersion.WithKind($(fn_strings_to_lower ${CRKind}).Kind)))
        return ownerReference
    }
EOF
    gofmt -w pkg/operator/$(fn_strings_to_lower ${CRKind})/util.go
}

##############################################################################
#                       CRD manifest 自动注册相关的部分                         #
##############################################################################
function fn_gen_package_pkg_crd() {
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    GROUP_VERSION=$(fn_strings_to_lower ${3})
    CRKind=$(fn_strings_first_upper $(fn_strings_to_lower ${4}))

    mkdir -pv pkg/crd/
    cat >> pkg/crd/install.go << EOF
    package crd

    import (
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/crd/$(fn_strings_to_lower ${CRKind})"
      "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/crd/register"

      extensionapiv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
      extensionclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
    )

    func InstallCustomResourceDefineToApiServer(extClientSet extensionclientset.Interface) error {
      crdResourceList := []*extensionapiv1.CustomResourceDefinition{}
      // register crd object
      crdResourceList = append(crdResourceList, $(fn_strings_to_lower ${CRKind}).New${CRKind}ResourceDefine())
      for _, crObj := range crdResourceList {
        if err := register.RegisterCRDWithObject(extClientSet, crObj); err != nil {
          return err
        }
        if err := register.WaitForCRDEstablished(extClientSet, crObj.GetName()); err != nil {
          return err
        }
      }
      return nil
    }
EOF
    gofmt -w pkg/crd/install.go

    cat >> pkg/crd/uninstall.go << EOF
        package crd
        import (
          "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/crd/$(fn_strings_to_lower ${CRKind})"
          "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/crd/register"

          extensionapiv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
          extensionclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
        )
        func UnInstallCustomResourceDefineToApiServer(extClientSet extensionclientset.Interface) error {
        	crdResourceList := []*extensionapiv1.CustomResourceDefinition{}
        	// register crd object
        	crdResourceList = append(crdResourceList, $(fn_strings_to_lower ${CRKind}).New${CRKind}ResourceDefine())
        	for _, crObj := range crdResourceList {
        		register.UnregisterCRD(extClientSet, crObj.GetName())
        	}
        	return nil
        }
EOF
    gofmt -w pkg/crd/uninstall.go

    mkdir -pv pkg/crd/register
    cat >> pkg/crd/register/register.go << EOF
    package register

    import (
    	"context"
    	"os"
    	"syscall"

    	extensionapiv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
    	extensionclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
    	"k8s.io/apimachinery/pkg/util/yaml"

    	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    )

    func RegisterCRDWithFile(namespace string, extClientSet extensionclientset.Interface, filename string) error {
    	crd := new(extensionapiv1.CustomResourceDefinition)
    	fp, err := os.OpenFile(filename, syscall.O_RDONLY, os.ModePerm)
    	if err != nil {
    		return err
    	}
    	decoder := yaml.NewYAMLToJSONDecoder(fp)
    	if err := decoder.Decode(crd); err != nil {
    		return err
    	}
    	crd.SetNamespace(namespace)
    	return RegisterCRDWithObject(extClientSet, crd)
    }

    // RegisterCRDWithObject register crd
    func RegisterCRDWithObject(extClient extensionclientset.Interface, crdObj *extensionapiv1.CustomResourceDefinition) error {
    	if _, err := extClient.ApiextensionsV1().CustomResourceDefinitions().Create(context.TODO(), crdObj, metav1.CreateOptions{}); err != nil {
    		return err
    	}
    	return nil
    }

    func UnregisterCRD(extClientSet extensionclientset.Interface, crdName string) error {
    	return extClientSet.ApiextensionsV1().CustomResourceDefinitions().Delete(context.TODO(), crdName, metav1.DeleteOptions{})
    }

EOF
    gofmt -w pkg/crd/register/register.go

    cat >> pkg/crd/register/waitcrd.go << EOF
    package register

    import (
    	"context"
    	"errors"
    	"time"

    	extensionapiv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
    	extensionclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
    	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    	"k8s.io/apimachinery/pkg/util/wait"
    	"k8s.io/klog/v2"
    )

    func WaitForCRDEstablished(extClientSet extensionclientset.Interface, crdName string) error {
    	return wait.Poll(1250*time.Millisecond, 10*time.Second, func() (done bool, err error) {
    		crd, err := extClientSet.ApiextensionsV1().CustomResourceDefinitions().Get(context.TODO(), crdName, metav1.GetOptions{})
    		klog.Infof("crd info : %v\n %v\n", crd.GetName(), crd.GetNamespace())
    		if err != nil {
    			return false, err
    		}
    		for _, cond := range crd.Status.Conditions {
    			switch cond.Type {
    			case extensionapiv1.NamesAccepted:
    				if cond.Status == extensionapiv1.ConditionFalse {
    					return false, errors.New("CRD Name Conflict")
    				}
    			case extensionapiv1.Established:
    				if cond.Status == extensionapiv1.ConditionTrue {
    					return true, nil
    				}
    			}
    		}
    		return false, err
    	})
    }
EOF
    gofmt -w pkg/crd/register/waitcrd.go

    mkdir -pv pkg/crd/$(fn_strings_to_lower ${CRKind})/
    cat >> pkg/crd/$(fn_strings_to_lower ${CRKind})/crd.go << EOF
    package $(fn_strings_to_lower ${CRKind})

    import (

    	crdapi${GROUP_VERSION} "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/$(fn_strings_to_lower ${GROUP_NAME})/$(fn_strings_to_lower ${GROUP_VERSION})"
    	extensionapiv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
    	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    )

    const (
    	jsonSchemePropsTypeAsInteger string = "integer"
    	jsonSchemePropsTypeAsString  string = "string"
    	jsonSchemePropsTypeAsObject  string = "object"
    	jsonSchemePropsTypesAsNumber string = "number"
    	jsonSchemePropsTypeAsArray   string = "array"
    )

    func New${CRKind}ResourceDefine() *extensionapiv1.CustomResourceDefinition {
    	crd := &extensionapiv1.CustomResourceDefinition{
    		ObjectMeta: metav1.ObjectMeta{
    			Name: "$(fn_strings_to_lower ${CRKind})" + "." + crdapi${GROUP_VERSION}.SchemeGroupVersion.Group,
    		},
    		Spec: extensionapiv1.CustomResourceDefinitionSpec{
    			Group: crdapi${GROUP_VERSION}.SchemeGroupVersion.Group,
    			Names: extensionapiv1.CustomResourceDefinitionNames{
    				Plural:   "$(fn_strings_to_lower ${CRKind})s",
    				Singular: "$(fn_strings_to_lower ${CRKind})",
    				Kind:     "${CRKind}",
    				ListKind: "${CRKind}List",
    			},
    			Scope: extensionapiv1.ResourceScope(extensionapiv1.NamespaceScoped),
    			Versions: []extensionapiv1.CustomResourceDefinitionVersion{
    				{
    					Name:    crdapi${GROUP_VERSION}.Version,
    					Served:  true,
    					Storage: true,
    					Schema: &extensionapiv1.CustomResourceValidation{
    						OpenAPIV3Schema: &extensionapiv1.JSONSchemaProps{
    							Type: jsonSchemePropsTypeAsObject,
    							Properties: map[string]extensionapiv1.JSONSchemaProps{
    								"apiVersion": {Type: jsonSchemePropsTypeAsString},
    								"kind":       {Type: jsonSchemePropsTypeAsString},
    								"metadata":   {Type: jsonSchemePropsTypeAsObject},
    								"spec": {
    									Type: jsonSchemePropsTypeAsObject,
    									Properties: map[string]extensionapiv1.JSONSchemaProps{
    										"replicas": {Type: jsonSchemePropsTypeAsInteger},
    										"image":    {Type: jsonSchemePropsTypeAsString},
    									},
    								},
    							},
    							Required: []string{"apiVersion", "kind", "metadata", "spec"},
    						},
    					},
    					Subresources:             &extensionapiv1.CustomResourceSubresources{},
    				},
    			},
    			PreserveUnknownFields: false,
    		},
    	}
    	return crd
    }

EOF
    gofmt -w pkg/crd/$(fn_strings_to_lower ${CRKind})/crd.go
}

##############################################################################
#                       CRD Constant 自动注册相关的部分                         #
##############################################################################
function fn_gen_package_pkg_config() {
        PROJECT_NAME=$(fn_strings_to_lower ${1})
        GROUP_NAME=$(fn_strings_to_lower ${2})
        GROUP_VERSION=$(fn_strings_to_lower ${3})
        CRKind=$(fn_strings_first_upper $(fn_strings_to_lower ${4}))

        mkdir pkg/config
        cat >> pkg/config/constant.go << EOF
        package config

        import (
        	crgroup "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/${GROUP_NAME}"
        	crapi${GROUP_VERSION} "$(fn_project_to_gomod ${PROJECT_NAME})/pkg/apis/${GROUP_NAME}/${GROUP_VERSION}"
        )

        const (
        	${CRKind}LabelAnnotationPrefix = crgroup.GroupName + "/" + crapi${GROUP_VERSION}.Version
        	${CRKind}AppNameLabel          = ${CRKind}LabelAnnotationPrefix + "app-name"
        )
EOF
        gofmt -w pkg/config/constant.go

}


##############################################################################
#                       测试相关的组件相关的部分                                  #
##############################################################################

function fn_gen_package_pkg_k8s_testing(){
    PROJECT_NAME=$(fn_strings_to_lower ${1})
    GROUP_NAME=$(fn_strings_to_lower ${2})
    GROUP_VERSION=$(fn_strings_to_lower ${3})
    RESOURCE_KIND=$(fn_strings_to_lower ${4})  # 资源类型
    CRKind=$(fn_strings_first_upper ${RESOURCE_KIND})    #CRKind 名称，首字母要大写

    mkdir  -pv pkg/k8s/testing
    cat >> pkg/k8s/testing/action.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

    package testing

    import (
        "fmt"
        apiappsv1 "k8s.io/api/apps/v1"
        apicorev1 "k8s.io/api/core/v1"
        "k8s.io/apimachinery/pkg/runtime"
        "k8s.io/apimachinery/pkg/runtime/schema"
        kubediff "k8s.io/apimachinery/pkg/util/diff"
        k8stest "k8s.io/client-go/testing"
        "reflect"

        crapi${GROUP_VERSION} "$(fn_project_to_gomod)/pkg/apis/${GROUP_NAME}/${GROUP_VERSION}"
    )

    // Validate validate action
    func ActionValidate(expected, actual k8stest.Action) error {
        if !(expected.Matches(actual.GetVerb(), actual.GetResource().Resource) && actual.GetSubresource() == expected.GetSubresource()) {
            return fmt.Errorf("Expected\n\t%#v\ngot\n\t%#v", expected, actual)
        }
        if reflect.TypeOf(expected) != reflect.TypeOf(actual) {
            return fmt.Errorf("Actions has wrong type. Expected : %t . Got %t ", expected, actual)
        }

        switch actAction := actual.(type) {
        case k8stest.CreateActionImpl:
            expAction, _ := expected.(k8stest.CreateActionImpl)
            expObject := expAction.GetObject()
            actObject := actAction.GetObject()
            if !reflect.DeepEqual(expObject, actObject) {
                return fmt.Errorf("Action %s %s has wrong object \n Diff :\n %s", actAction.GetVerb(), actAction.GetResource().Resource, kubediff.ObjectGoPrintSideBySide(expObject, actObject))
            }
        case k8stest.UpdateActionImpl:
            expAction, _ := expected.(k8stest.UpdateActionImpl)
            expObject := expAction.GetObject()
            actObject := actAction.GetObject()
            if !reflect.DeepEqual(expObject, actObject) {
                return fmt.Errorf("Action %s %s has wrong object \n Diff :\n %s", actAction.GetVerb(), actAction.GetResource().Resource, kubediff.ObjectGoPrintSideBySide(expObject, actObject))
            }
        case k8stest.PatchActionImpl:
            expAction, _ := expected.(k8stest.PatchActionImpl)
            expPath := expAction.GetPatch()
            actPatch := actAction.GetPatch()
            if !reflect.DeepEqual(expPath, actPatch) {
                return fmt.Errorf("Action %s %s has wrong object \n Diff :\n %s", actAction.GetVerb(), actAction.GetResource().Resource, kubediff.ObjectGoPrintSideBySide(expPath, actPatch))
            }
        default:
            return fmt.Errorf("Uncaptured action %s %s, you should explicity add a case to capture it ", actual.GetVerb(), actual.GetResource().Resource)
        }
        return nil
    }

    // Pod Action Creator

    // ExpectCreatePodAction return pod's CreateAction
    func ExpectCreatePodAction(pod *apicorev1.Pod)k8stest.Action{
        return k8stest.NewCreateAction(schema.GroupVersionResource{Resource: "pods"}, pod.GetNamespace(), pod)
    }

    // ExpectUpdatePodAction return pod's UpdateAction
    func ExpectUpdatePodAction(pod *apicorev1.Pod)k8stest.Action{
        return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "pods"} , pod.GetNamespace(), pod)
    }

    // ExpectGetPodAction return pod's GetAction
    func ExpectGetPodAction(pod *apicorev1.Pod)k8stest.Action{
        return k8stest.NewGetAction(schema.GroupVersionResource{Resource: "pods"}, pod.GetNamespace(), pod.GetName())
    }

    // Deployment Action Creator

    // ExpectCreateDeploymentAction return deployment's CreateAction
    func ExpectCreateDeploymentAction(dpl *apiappsv1.Deployment) k8stest.Action {
        return k8stest.NewCreateAction(schema.GroupVersionResource{Resource: "deployments"}, dpl.GetNamespace(), dpl)
    }

    // ExpectUpdateDeploymentAction return deployment's UpdateAction
    func ExpectUpdateDeploymentAction(dpl *apiappsv1.Deployment) k8stest.Action {
        return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "deployments"}, dpl.GetNamespace(), dpl)
    }

    // ExpectGetDeploymentAction return deployment's GetAction
    func ExpectGetDeploymentAction(dpl *apiappsv1.Deployment)k8stest.Action{
        return k8stest.NewGetAction(schema.GroupVersionResource{Resource: "deployments"}, dpl.GetNamespace(), dpl.GetName())
    }

    // DaemonSet Action Creator

    // ExpectCreateDaemonSetAction return daemonSet's CreateAction
    func ExpectCreateDaemonSetAction(ds *apiappsv1.DaemonSet) k8stest.Action {
        return k8stest.NewCreateAction(schema.GroupVersionResource{Resource: "daemonsets"}, ds.GetNamespace(), ds)
    }

    // ExpectUpdateDaemonSetAction return daemonSet's UpdateAction
    func ExpectUpdateDaemonSetAction(ds *apiappsv1.DaemonSet) k8stest.Action {
        return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "daemonsets"}, ds.GetNamespace(), ds)
    }

    // ExpectGetDaemonSetAction return daemonSet's GetAction
    func ExpectGetDaemonSetAction(ds *apiappsv1.DaemonSet)k8stest.Action{
        return k8stest.NewGetAction(schema.GroupVersionResource{Resource: "daemonsets"}, ds.GetNamespace(), ds.GetName())
    }

    // StatefulSet Action Creator

    // ExpectCreateStatefulSetAction return statefulSet's CreateAction
    func ExpectCreateStatefulSetAction(sts *apiappsv1.StatefulSet)k8stest.Action{
        return k8stest.NewCreateAction(schema.GroupVersionResource{Resource: "statefulsets"}, sts.GetNamespace(), sts)
    }

    // ExpectUpdateStatefulSetAction return statefulSet's UpdateAction
    func ExpectUpdateStatefulSetAction(sts *apiappsv1.StatefulSet)k8stest.Action{
        return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "statefulsets"}, sts.GetNamespace(), sts)
    }

    // ExpectGetStatefulSetAction return statefulSet's GetAction
    func ExpectGetStatefulSetAction(sts *apiappsv1.StatefulSet)k8stest.Action{
        return k8stest.NewGetAction(schema.GroupVersionResource{Resource: "statefulsets"}, sts.GetNamespace(), sts.GetName())
    }

    // Service Action Creator

    // ExpectCreateServiceAction return service's CreateAction
    func ExpectCreateServiceAction(svc *apicorev1.Service) k8stest.Action {
        return k8stest.NewCreateAction(schema.GroupVersionResource{Resource: "services"}, svc.GetNamespace(), svc)
    }

    // ExpectUpdateServiceAction return service's UpdateAction
    func ExpectUpdateServiceAction(svc *apicorev1.Service) k8stest.Action {
        return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "services"}, svc.GetNamespace(), svc)
    }

    // ExpectGetServiceAction return service's GetAction
    func ExpectGetServiceAction(svc *apicorev1.Service)k8stest.Action{
        return k8stest.NewGetAction(schema.GroupVersionResource{Resource: "services"}, svc.GetNamespace(),svc.GetName())
    }

    // ConfigMap Action Creator

    // ExpectCreateConfigMapAction return create configMap action
    func ExpectCreateConfigMapAction(cm *apicorev1.ConfigMap) k8stest.Action {
        return k8stest.NewCreateAction(schema.GroupVersionResource{Resource: "configmaps"}, cm.GetNamespace(), cm)
    }

    // ExpectUpdateConfigMapAction return update configMap action
    func ExpectUpdateConfigMapAction(cm *apicorev1.ConfigMap) k8stest.Action {
        return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "configmaps"}, cm.GetNamespace(), cm)
    }

    // ExpectGetConfigMapAction return get configMap action
    func ExpectGetConfigMapAction(cm *apicorev1.ConfigMap)k8stest.Action{
        return k8stest.NewGetAction(schema.GroupVersionResource{Resource: "configmaps"}, cm.GetNamespace(), cm.GetName())
    }

    // CustomResource Action Creator

    // for custom resource actions
    func ExpectUpdateCustomResourceAction(cr runtime.Object)k8stest.Action{
        switch cr.GetObjectKind().GroupVersionKind().Kind {
        case "${CRKind}":
            return k8stest.NewUpdateAction(schema.GroupVersionResource{Resource: "$(fn_strings_to_lower ${CRKind})s"}, cr.(*crapi${GROUP_VERSION}.${CRKind}).GetNamespace(), cr)
        }
        return nil
    }

    func ExpectUpdateCustomResourceStatusAction(cr runtime.Object)k8stest.Action{
        switch cr.GetObjectKind().GroupVersionKind().Kind {
        case "${CRKind}":
            return k8stest.NewUpdateSubresourceAction(schema.GroupVersionResource{Resource: "$(fn_strings_to_lower ${CRKind})"}, "status",cr.(*crapi${GROUP_VERSION}.${CRKind}).GetNamespace(), cr)
        }
        return nil
    }
EOF
    gofmt -w pkg/k8s/testing/action.go

    cat >> pkg/k8s/testing/fixture.go << EOF
/*
Copyright `date "+%Y"` The ${PROJECT_NAME} Authors.
Licensed under the Apache License, PROJECT_VERSION 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package testing

    import (
        "fmt"
        apiappsv1 "k8s.io/api/apps/v1"
        apicorev1 "k8s.io/api/core/v1"
        "k8s.io/apimachinery/pkg/runtime"
        "k8s.io/client-go/informers"
        k8sfake "k8s.io/client-go/kubernetes/fake"
        k8stest "k8s.io/client-go/testing"

        "$(fn_project_to_gomod)/pkg/operator"
        crapi${GROUP_VERSION} "$(fn_project_to_gomod)/pkg/apis/${GROUP_NAME}/${GROUP_VERSION}"
        crinformers "$(fn_project_to_gomod)/pkg/client/informers/externalversions"
        crfakeclients "$(fn_project_to_gomod)/pkg/client/clientset/versioned/fake"
    )

    type Fixture struct {
        kubeClient *k8sfake.Clientset
        crClient *crfakeclients.Clientset

        // Object to put in the store
        podLister        []*apicorev1.Pod
        deploymentLister []*apiappsv1.Deployment
        statefulSet      []*apiappsv1.StatefulSet
        daemonSet        []*apiappsv1.DaemonSet
        serviceLister    []*apicorev1.Service
        configMapLister  []*apicorev1.ConfigMap
        // for custom resource
        customListers    []*runtime.Object

        // TODO write your code here
        kubeInformers informers.SharedInformerFactory
        crInformers   crinformers.SharedInformerFactory

        // Actions expected to happen on client.
        kubeActions           []k8stest.Action
        customResourceActions []k8stest.Action

        // Objects from here preloaded into NewSimpleFake
        kubeObjects           []runtime.Object
        customResourceObjects []runtime.Object

        // operator
        operator operator.Operator
    }

    func NewFixture(k8sFakeClient *k8sfake.Clientset, crFakeClient *crfakeclients.Clientset,
        kubeInformers informers.SharedInformerFactory, crInformers crinformers.SharedInformerFactory)*Fixture{
        return &Fixture{kubeClient: k8sFakeClient, crClient: crFakeClient, kubeInformers: kubeInformers, crInformers: crInformers}
    }

    func (f *Fixture) AddPodLister(pods ...*apicorev1.Pod) error {
        for _, pod := range pods {
            if err := f.kubeInformers.Core().V1().Pods().Informer().GetIndexer().Add(pod); err != nil {
                return err
            }
        }
        return nil
    }

    func (f *Fixture) AddDeploymentLister(dpls ...*apiappsv1.Deployment) error {
        for _, dpl := range dpls {
            if err := f.kubeInformers.Apps().V1().Deployments().Informer().GetIndexer().Add(dpl); err != nil {
                return err
            }
        }
        return nil
    }

    func (f *Fixture) AddStatefulSetLister(sts ...*apiappsv1.StatefulSet) error {
        for _, st := range sts {
            if err := f.kubeInformers.Apps().V1().StatefulSets().Informer().GetIndexer().Add(st); err != nil {
                return err
            }
        }
        return nil
    }

    func (f *Fixture) AddDaemonSetLister(dss ...*apiappsv1.DaemonSet) error {
        for _, ds := range dss {
            if err := f.kubeInformers.Apps().V1().DaemonSets().Informer().GetIndexer().Add(ds); err != nil {
                return err
            }
        }
        return nil
    }

    func (f *Fixture) AddServiceLister(svs ...*apicorev1.Service) error {
        for _, sv := range svs {
            if err := f.kubeInformers.Core().V1().Services().Informer().GetIndexer().Add(sv); err != nil {
                return err
            }
        }
        return nil
    }

    func (f *Fixture) AddConfigMapLister(cms ...*apicorev1.ConfigMap) error {
        for _, cm := range cms {
            if err := f.kubeInformers.Core().V1().ConfigMaps().Informer().GetIndexer().Add(cm); err != nil {
                return err
            }
        }
        return nil
    }

    func (f *Fixture) AddCustomResourceLister(cr runtime.Object) error {
        f.customResourceObjects = append(f.customResourceObjects, cr)
        switch cr.GetObjectKind().GroupVersionKind().Kind {
        default:
            return fmt.Errorf("Unexpect Custom Resource Type %s %s ", cr.GetObjectKind().GroupVersionKind().Kind, cr.GetObjectKind().GroupVersionKind().GroupVersion())
        }
        return nil
    }

    // add expect actions
    func(f *Fixture)PutKubeActions(kubeActions  ...k8stest.Action){
        f.kubeActions = append(f.kubeActions, kubeActions...)
    }

    func(f *Fixture)PutCustomResourceActions(crActions ...k8stest.Action){
        f.customResourceActions = append(f.customResourceActions, crActions...)
    }


    func(f *Fixture)GetKubeActions()[]k8stest.Action{
        return f.kubeActions
    }

    func(f *Fixture)GetCustomResourceActions()[]k8stest.Action{
        return f.customResourceActions
    }


EOF
    gofmt -w pkg/k8s/testing/fixture.go
}

# 初始化项目
mkdir -pv ${PROJECT_NAME}/hack && cp $0 ${PROJECT_NAME}/hack/
cd ${PROJECT_NAME} && go mod init $(fn_project_to_gomod ${PROJECT_NAME})
# mkdir e2e test package
mkdir -pv e2e



# 创建GVR 相关文件
# 开始执行
echo "Begin generate some necessary code file"
# 生成register.go文件
fn_gen_gofile_group_register ${PROJECT_NAME} ${GROUP_NAME}
# 生成group doc文件
fn_gen_gofile_group_version_doc ${PROJECT_NAME} ${GROUP_NAME} ${PROJECT_VERSION}
# 生成group types文件
fn_gen_gofile_group_version_types  ${PROJECT_NAME} ${GROUP_NAME} ${PROJECT_VERSION} ${CRKind}
# 生成 register文件
fn_gen_gofile_group_version_register ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION} ${CRKind}
# 生成配置文件
fn_gen_gofile_install_install ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION}
#
#
## cmd相关 main.go
fn_gen_gofile_cmd_project_main  ${PROJECT_NAME}
# signals.go
fn_gen_gofile_cmd_projct_signals ${PROJECT_NAME}
# start.go
fn_gen_gofile_cmd_project_startcmd ${PROJECT_NAME} ${GROUP_NAME} ${PROJECT_VERSION}
# options interface
fn_gen_gofile_cmd_project_options_interface ${PROJECT_NAME}
# /options
fn_gen_gofile_cmd_project_options_options ${PROJECT_NAME}
#

# controller package
fn_gen_gofile_pkg_controller_interfaces ${PROJECT_NAME}
# crdcontroller
fn_gen_package_pkg_controller_CRKind ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION} ${CRKind}
# opetator
fn_gen_package_pkg_operator_interfaces ${PROJECT_NAME}
fn_gen_package_pkg_operator_crdoperator  ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION} ${CRKind}

# crd auto register
fn_gen_package_pkg_crd ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION} ${CRKind}

# config
fn_gen_package_pkg_config ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION} ${CRKind}

# test
fn_gen_package_pkg_k8s_testing ${PROJECT_NAME} ${GROUP_NAME} ${GROUP_VERSION}  ${CRKind}

