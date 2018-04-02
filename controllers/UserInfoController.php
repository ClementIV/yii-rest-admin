<?php

namespace clement\rest\controllers;

use Yii;
use yii\web\NotFoundHttpException;
use clement\rest\components\Helper;
use clement\rest\components\MenuHelper;
use yii\web\User;
use yii\rest\Controller;
class UserInfoController extends Controller
{
    public function actionIndex(){
        $user = Yii::$app->getUser();
        $userId = $user instanceof User ? $user->getId() : $user;
        $res['menu'] = MenuHelper::getAssignedMenu($userId);
        $res['resources'] = Helper::getPermissionByUser($userId);
        return $res;

    }
}

?>
