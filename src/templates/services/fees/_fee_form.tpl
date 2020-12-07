<?php
assert(isset($legend));
assert(isset($csrf_key));
assert(isset($submit_label));
$targets = Entities\Accounting\Account::TYPE_REVENUE;
?>

{form_errors}

<form method="post" action="{$self_url}" data-focus="1">

	<fieldset>
		<legend>{$legend}</legend>
		<dl>
			{input name="label" type="text" required=1 label="Libellé" source=$fee}
			{input name="description" type="textarea" label="Description" source=$fee}

			<dt><label for="f_amount_type">Montant de la cotisation</label></dt>
			{input name="amount_type" type="radio" value="0" label="Gratuite ou prix libre" default=$amount_type}
			{input name="amount_type" type="radio" value="1" label="Montant fixe ou prix libre conseillé" default=$amount_type}
			<dd class="amount_type_1">
				<dl>
					{input name="amount" type="money" label="Montant" source=$fee fake_required=1}
				</dl>
			</dd>
			{input name="amount_type" type="radio" value="2" label="Montant variable" default=$amount_type}
			<dd class="amount_type_2">
				<dl>
					{input name="formula" type="textarea" label="Formule de calcul" source=$fee fake_required=1}
					<dd class="help">
						<a href="https://fossil.kd2.org/garradin/wiki?name=Formule_calcul_activit%C3%A9">Aide sur les formules de calcul</a>
					</dd>
				</dl>
			</dd>
			<dt><strong>Comptabilité</strong></dt>
			{input name="accounting" type="checkbox" value="1" label="Enregistrer en comptabilité" default=$accounting_enabled}
			<dd class="help">Laissez cette case décochée si vous n'utilisez pas Garradin pour la comptabilité. Il ne sera pas possible de suivre le montant des règlements effectués pour ce tarif.</dd>
		</dl>
	</fieldset>

	<fieldset class="accounting">
		<legend>Enregistrer en comptabilité</legend>
		<p class="help">Chaque règlement d'un membre lié à ce tarif sera enregistré dans la comptabilité, permettant de suivre le montant des règlements effectués.</p>
		{if !count($years)}
			<p class="error block">Il n'y a aucun exercice ouvert dans la comptabilité, il n'est donc pas possible d'enregistrer les activités dans la comptabilité. Merci de commencer par <a href="{$admin_url}acc/years/new.php">créer un exercice</a>.</p>
		{else}
		<dl>
			<dt><label for="f_id_year">Exercice</label> <b>(obligatoire)</b></dt>
			<dd>
				<select id="f_id_year" name="id_year">
					{foreach from=$years item="year"}
					<option value="{$year.id}">{$year.label} — {$year.start_date|date_short} au {$year.end_date|date_short}</option>
					{/foreach}
				</select>
			</dd>
			{input type="list" target="acc/charts/accounts/selector.php?targets=%s&year=%d"|args:$targets,$fee.id_year name="account" label="Compte à utiliser" default=$account required=1}
		</dl>
		{/if}
	</fieldset>

	<p class="submit">
		{csrf_field key=$csrf_key}
		{button type="submit" name="save" label="Enregistrer" shape="right" class="main"}
	</p>

</form>

<script type="text/javascript">
{literal}
(function () {
	var hide = [];
	if (!$('#f_amount_type_1').checked)
		hide.push('.amount_type_1');

	if (!$('#f_amount_type_2').checked)
		hide.push('.amount_type_2');

	g.toggle(hide, false);
	g.toggle('.accounting', $('#f_accounting_1').checked);

	function togglePeriod()
	{
		g.toggle(['.amount_type_1', '.amount_type_2'], false);

		if (this.checked && this.value == 1)
			g.toggle('.amount_type_1', true);
		else if (this.checked && this.value == 2)
			g.toggle('.amount_type_2', true);
	}

	$('#f_amount_type_0').onchange = togglePeriod;
	$('#f_amount_type_1').onchange = togglePeriod;
	$('#f_amount_type_2').onchange = togglePeriod;
	$('#f_accounting_1').onchange = () => { g.toggle('.accounting', $('#f_accounting_1').checked); };

	function toggleYearForSelector()
	{
		var btn = document.querySelector('#f_account_container button');
		btn.value = btn.value.replace(/year=\d+/, 'year=' + y.value);
	}

	var y = $('#f_id_year')

	y.onchange = toggleYearForSelector;
	toggleYearForSelector();
})();
{/literal}
</script>