<?php
namespace Garradin;

use Garradin\Services\Services_User;
use Garradin\Entities\Accounting\Account;
use Garradin\Entities\Accounting\Transaction;

require_once __DIR__ . '/../_inc.php';

$session->requireAccess($session::SECTION_USERS, $session::ACCESS_WRITE);

$su = Services_User::get((int)qg('id'));

if (!$su) {
	throw new UserException("Cette inscription n'existe pas");
}

$user_name = (new Membres)->getNom($su->id_user);

$csrf_key = 'service_pay';

$form->runIf(f('save') || f('save_and_add_payment'), function () use ($su, $session) {
	$su->addPayment($session->getUser()->id);

	if ($su->paid != (bool) f('paid')) {
		$su->paid = (bool) f('paid');
		$su->save();
	}

	if (f('save_and_add_payment')) {
		$url = ADMIN_URL . 'services/user/payment.php?id=' . $su->id;
	}
	else {
		$url = ADMIN_URL . 'services/user/?id=' . $su->id_user;
	}

	Utils::redirect($url);
}, $csrf_key);

$types_details = Transaction::getTypesDetails();
$account_targets = $types_details[Transaction::TYPE_REVENUE]->accounts[1]->targets_string;

$tpl->assign(compact('csrf_key', 'account_targets', 'user_name', 'su'));

$tpl->display('services/user/payment.tpl');