## Yii-rest-rbac 后台RBAC配置
---
### 写在前面
本篇只讲述如何使用`Yii-rest-rbac`进行 `restful API`认证和权限管理，关于原理，请移步
[Yii-REST-RBAC原理]()(目前未完成)
### 下载安装

```
    composer require clement/yii-rest-rbac
or
    php composer.phar require clement/yii-rest-rbac  
```
### 创建数据表
1. 使用`@vendor\\clement\\yii-rest-rbac\\migrations`下的 `yii-rest-rbac.sql` 导入到数据库中
2. 你可以修改`表前缀cc_`或者在数据库配置中添加
```
    'tablePrefix' =>'cc_',
```
### 配置文件
1. 在`app`(**backend**/ **common** )的`main.php`中添加

```
'modules' => [
    "admin" => [
        "class" => "clement\\rest\Module",
        'layout' => 'left-menu',//yii2-admin的导航菜单
    ],
],
"aliases" => [
        "@clement/rest" => "@vendor/clement/yii-rest-rbac",
    ],
'components' => [
    'jwt' => [
        'class' => 'clement\rest\auth\Jwt',
        'key' => 'xxx', // 你自己的想使用的key，注意保密
            ],
    'user' => [
        'identityClass' =>'xxxx\User',//自己的User model
        'enableAutoLogin' => true,
        'enableSession' =>false,
        'loginUrl' => null,   // api ++
    ],
    "authManager" => [
        "class" => 'clement\\rest\components\DbManager',
        'defaultRoles' => ['游客'], //添加此行代码，指定默认规则为 '未登录用户'
    ],
    /**
     * 根据需要设置有无,具体的参照 yii-rest-rbac原理文档
     *
     */
     'as access' => [
         'class' => 'clement\\rest\components\AccessControl',
         'allowActions' => [
             '*',//根据自己的情况设置
         ]

```
2. 在`User`中添加以下函数 (==注意函数中xxx参数需要自己修改==)
```
    /**
     * {@inheritdoc}
     */
    public function loginByAccessToken($token, $type = null)
    {
        return static::findIdentityByAccessToken($token, $type);
    }


    /**
     * Validates access_token.
     *
     * @param string $token token to validate
     *
     * @return bool if token provided is valid for current user
     */
    public static function isAccessTokenValid($token)
    {
        if (empty($token)) {
            return false;
        }
        $data = Yii::$app->jwt->getValidationData(); // It will use the current time to validate (iat, nbf and exp)
        $data->setIssuer('xxxx1'); //xxxx1 自己填
        $data->setAudience('xxxx2'); // xxxx2 自己填
        $data->setId('xxxx3', true);  // xxxx3 自己填
        if (is_string($token))
            $token = Yii::$app->jwt->getParser()->parse($token);

        return $token->validate($data);
    }



    /**
     * Generates new api access token.
     */
    public function generateAccessToken()
    {

        // $this->access_token = Yii::$app->security->generateRandomString() . '_' . time();
        $signer = new Sha256();
        $token = Yii::$app->jwt->getBuilder()->setIssuer('xxxx1')// Configures the issuer (iss claim) //对应上面 xxxx1
        ->setAudience('xxxx2')// Configures the audience (aud claim) // 对应于上面的 xxxx2
        ->setId('xxxx3', true) //对应于上面的 xxxx3
            ->setExpiration(time() + Yii::$app->params['accessTokenExpire'])// Configures exp time
            ->setIssuedAt(time())// Configures the time that the token was issue (iat claim)

            ->sign($signer, Yii::$app->jwt->key)
            ->getToken(); // Retrieves the generated token
        $this->access_token = (string)$token;
    }

    /**
     * findIdentityByAccessToken find User Identity  
     *
     */
    public static function findIdentityByAccessToken($token, $type = null)
    {
        // if token is not valid
        if (!static::isAccessTokenValid($token)) {
            throw new \yii\web\UnauthorizedHttpException('token is invalid.');
        }

        return static::findOne(['access_token' => $token, 'status' => self::STATUS_ACTIVE]);
         // throw new NotSupportedException('"findIdentityByAccessToken" is not implemented.');
    }

```
3. 在`LoginForm`中添加
```
    const GET_ACCESS_TOKEN = 'generate_access_token';

    public function init()
    {
        parent::init();
        $this->on(self::GET_ACCESS_TOKEN, [$this, 'onGenerateAccessToken']);
    }

    /**
     * Logs in a user using the provided username and password.
     *
     * @return boolean whether the user is logged in successfully
     */
    public function login()
    {
        if ($this->validate()) {
            $this->trigger(self::GET_ACCESS_TOKEN);
            return $this->_user;
        } else {
            return null;
        }
    }

    /**
    * 登录校验成功后，为用户生成新的token
    * 如果token失效，则重新生成token
    */
    public function onGenerateAccessToken()
    {
        if (!User::isAccessTokenValid($this->_user->access_token)) {
            $this->_user->generateAccessToken();
            $this->_user->save(false);
        }
    }
```  
4. 使用认证
 * 创建所有`api`控制器基类
```
use clement\rest\auth\APIAuth;
use clement\rest\components\AccessControl;
class BaseController extends ActiveController
{
    /**
     * 设置返回头部的allow部分
     * @param array $collection allow的方法集合
     */
    public function ResponseOptions($collection = [])
    {
        $collectionOptions = ['GET', 'POST', 'HEAD', 'OPTIONS'];
        if(!empty($collection)){
            $collectionOptions = $collection;
        }
        Yii::$app->getResponse()->getHeaders()->set('Allow', implode(', ', $collectionOptions));

    }
    public function behaviors()
    {
        $behaviors = parent::behaviors();        

        // add CORS filter
        // 处理跨域请求，注意设置生产版本的 Origin
        $behaviors['corsFilter'] = [
            'class' => Cors::className(),
            'cors' => [
                'Origin' => ['*'],
                'Access-Control-Allow-Origin' => ['*'],
                'Access-Control-Request-Method' => ['*'],
                'Access-Control-Request-Headers' => ['*'],
                'Access-Control-Allow-Credentials' => true,
                'Access-Control-Max-Age' => 86400,
            ]
        ];
        // 设置认证的方式
        $behaviors['authenticator'] = [
           'class' => APIAuth::className(),
           'except' => ['OPTIONS'],
        ];
        // 设置权限验证方式
        $behaviors['access'] = [
                      'class' => AccessControl::className(),
                  ];
        return $behaviors;
    }
}
```
 * 在`UserController`中修改`behaviors()`填加
```
    /**
     *
     * 使用jwt token 验证，并设置login signup不需要验证
     */

    public function behaviors()
    {
        $behaviors =  ArrayHelper::merge(
            parent::behaviors(), [
                'authenticator' => [
                    'optional' => ['login','signup']
                ],

            ]
        );
        return $behaviors;
    }
```
* 第一步使用`用户名/密码`获取`token`
```
    public function actionLogin()
    {
        $model = new LoginForm();
        $model->setAttributes(Yii::$app->request->post());
        try {
            if ($user = $model->login()) {
                return $user->access_token
            }
        } catch(yii\web\HttpException){
            throw new yii\web\HttpException;
        }

    }

```
* 第二步所有请求头部携带token
```
    Authorization:Bearer <your access-token>
```
5. 使用权限
 * 使用 `admin/route`的url 即可到后台管理，原理请参照yii的官方文档的RBAC
 * 如果需要将在下个版本提供所有页面的rest版
 * 现在提供的接口
```
<?php
// 命名空间注意修改
namespace xxxx\controllers;

use Yii;
use  yii\helpers\ArrayHelper;
use yii\web\NotFoundHttpException;
use clement\rest\components\Helper;
use clement\rest\components\MenuHelper;
use yii\web\User; // 注意不要使用其他的
use \base\BaseController;
class UserInfoController extends BaseController
{
    public $modelClass = 'xxxx\User'; // 上面修改的User，即认证的User类
    protected function verbs()
    {
        return  ArrayHelper::merge(
            parent::verbs(),
            [

                //关于options的严谨方法，需对options 处理
                'info' => ['GET','OPTIONS'],

            ]
        );
    }
    public function actionInfo(){
        $request = \Yii::$app->request;
        if($request->getIsOptions()){
            return $this->ResponseOptions( $this->verbs()['info']);
        }
        $user = Yii::$app->getUser();
        $userId = $user instanceof User ? $user->getId() : $user;
        $res['userInfo']['menus'] = MenuHelper::getAssignedMenu($userId);
        $res['userInfo']['resources'] = Helper::getPermissionByUser($userId);

        return $res;

    }
}
```
* 结果样例
```
{
  -"menu": [
    -{
        "id": "1",
        "name": "首页",
        "route": "/teacher-default",
        "parent_id": null
    }
  ],
  -"resources": [
    -{
        "url": "/admin/*",
        "method": "",
        "id": 1
    }
  ]
}
```

