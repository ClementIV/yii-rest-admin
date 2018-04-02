<?php

namespace clement\rest\auth;

use Yii;
use yii\di\Instance;
use yii\filters\auth\AuthMethod;

class APIAuth extends AuthMethod
{
    /**
     * @var string the HTTP authentication realm
     */
    public $realm = 'api';

    /**
     * @var Jwt|string|array the [[Jwt]] object or the application component ID of the [[Jwt]].
     */
    public $jwt = 'jwt';
    public $except = [];
    public $key ;
    /**
     * @inheritdoc
     */
    public function init()
    {
        parent::init();
        $this->jwt = Instance::ensure($this->jwt, Jwt::className());
        $this->key = Yii::$app->jwt->key;

    }

    /**
     * @inheritdoc
     */
    public function authenticate($user, $request, $response)
    {

        $authHeader = $request->getHeaders()->get('Authorization');
        $method = $request->method;
        if(in_array($method,$this->except)){
            return true;
        }

        if ($authHeader !== null && preg_match('/^Bearer\s+(.*?)$/', $authHeader, $matches)) {

            $token = $this->loadToken($matches[1]);

            if ($token === null) {
                $this->handleFailure($response);
            }

            $identity = $user->loginByAccessToken($token, get_class($this));
            return $identity;
        }

        return null;
    }

    /**
     * @inheritdoc
     */
    public function challenge($response)
    {
        $response->getHeaders()->set('WWW-Authenticate', "Bearer realm=\"{$this->realm}\"");
    }

    /**
     * Parses the JWT and returns a token class
     * @param string $token JWT
     * @return Token|null
     */
    public function loadToken($token)
    {
        return $this->jwt->loadToken($token);
    }
}
