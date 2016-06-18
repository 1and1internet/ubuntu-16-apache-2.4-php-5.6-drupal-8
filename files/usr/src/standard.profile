<?php
/**
 * @file
 * Enables modules and site configuration for a standard site installation.
 */

use Drupal\contact\Entity\ContactForm;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Component\Utility\Crypt;
use Drupal\Core\Database\Database;
use Drupal\Core\Site\Settings;

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function standard_form_install_configure_form_alter(&$form, FormStateInterface $form_state) {
  $form['#submit'][] = 'standard_form_install_configure_submit';
}

/**
 * Submission handler to sync the contact.form.feedback recipient.
 */
function standard_form_install_configure_submit($form, FormStateInterface $form_state) {
  $site_mail = $form_state->getValue('site_mail');
  ContactForm::load('feedback')->setRecipients([$site_mail])->trustData()->save();
}


function standard_install_tasks_alter(&$tasks, $install_state) {
  // Hide the database configuration step.
  $tasks['install_settings_form']['display'] = FALSE;
  $tasks['install_settings_form']['function'] = 'standard_1and1_install_settings_defaults';
  $tasks['install_settings_form']['type'] = 'normal';
}

function standard_1and1_install_settings_defaults(&$install_state){ 
  // Get variables in.
  $vars = array(
      'DRUPAL_DB_HOST',
      'DRUPAL_DB_PORT',
      'DRUPAL_DB_USER',
      'DRUPAL_DB_NAME',
      'DRUPAL_DB_PASSWORD',
      'DRUPAL_DB_DRIVER',
      'DRUPAL_DB_PREFIX'
  );
  foreach ($vars as $var) {
      if (!isset($_ENV[$var]) && getenv($var)) {
	  $_ENV[$var] = getenv($var);
      }
  } 
  // DB details array.
  $database = array (
	'driver' => $_ENV['DRUPAL_DB_DRIVER'],
	'database' => $_ENV['DRUPAL_DB_NAME'],
	'username' => $_ENV['DRUPAL_DB_USER'],
	'password' => $_ENV['DRUPAL_DB_PASSWORD'],
	'host' => $_ENV['DRUPAL_DB_HOST'],
	'port' => $_ENV['DRUPAL_DB_PORT'],
	'prefix' => isset($_ENV['DRUPAL_DB_PREFIX']) ? $_ENV['DRUPAL_DB_PREFIX'] : null,
  );

    // Update global settings array and save.
    $settings = array();
    $settings['databases']['default']['default'] = (object) array(
      'value'    => $database,
      'required' => TRUE,
    );
    $settings['settings']['hash_salt'] = (object) array(
      'value'    => Crypt::randomBytesBase64(55),
      'required' => TRUE,
    );
    // Remember the profile which was used.
    $settings['settings']['install_profile'] = (object) array(
      'value' => $install_state['parameters']['profile'],
      'required' => TRUE,
    );

    drupal_rewrite_settings($settings);

    // Add the config directories to settings.php.
    drupal_install_config_directories();

    // Indicate that the settings file has been verified, and check the database
    // for the last completed task, now that we have a valid connection. This
    // last step is important since we want to trigger an error if the new
    // database already has Drupal installed.
    $install_state['settings_verified'] = TRUE;
    $install_state['config_verified'] = TRUE;
    $install_state['database_verified'] = TRUE;
    $install_state['completed_task'] = install_verify_completed_task();
}
