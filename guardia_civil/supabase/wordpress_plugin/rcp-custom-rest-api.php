<?php
/**
 * Plugin Name: RCP Custom REST API Endpoint
 * Description: Endpoint personalizado para obtener niveles de membresía de RCP con todos los datos
 * Version: 1.1
 * Author: Pablo Fernández Lucas
 */

// Evitar acceso directo
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Registrar el endpoint personalizado
 */
add_action('rest_api_init', function () {
    register_rest_route('rcp-custom/v1', '/levels', array(
        'methods'  => 'GET',
        'callback' => 'rcp_custom_get_levels',
        'permission_callback' => 'rcp_custom_check_permissions',
    ));
});

/**
 * Verificar permisos
 */
function rcp_custom_check_permissions() {
    // Verificar que el usuario esté autenticado con JWT
    $user_id = get_current_user_id();
    
    if (!$user_id) {
        return new WP_Error(
            'rest_forbidden',
            'Debes estar autenticado para acceder a este endpoint',
            array('status' => 401)
        );
    }
    
    // Verificar que sea administrador
    if (!current_user_can('manage_options')) {
        return new WP_Error(
            'rest_forbidden',
            'No tienes permisos para acceder a este endpoint',
            array('status' => 403)
        );
    }
    
    return true;
}

/**
 * Obtener niveles de membresía desde la base de datos
 */
function rcp_custom_get_levels($request) {
    global $wpdb;
    
    // Verificar que RCP esté instalado
    if (!function_exists('rcp_get_subscription_levels')) {
        return new WP_Error(
            'rcp_not_found',
            'Restrict Content Pro no está instalado o activado',
            array('status' => 500)
        );
    }
    
    // Nombre de la tabla de niveles de RCP
    $table_name = $wpdb->prefix . 'restrict_content_pro';
    
    // Consultar todos los niveles
    $levels = $wpdb->get_results(
        "SELECT * FROM {$table_name} WHERE status = 'active' ORDER BY id ASC",
        ARRAY_A
    );
    
    if ($wpdb->last_error) {
        return new WP_Error(
            'database_error',
            'Error al consultar la base de datos: ' . $wpdb->last_error,
            array('status' => 500)
        );
    }
    
    if (empty($levels)) {
        return new WP_Error(
            'no_levels',
            'No se encontraron niveles de membresía activos',
            array('status' => 404)
        );
    }
    
    // Formatear los datos
    $formatted_levels = array();

    foreach ($levels as $level) {
        // Log para debug - ver qué campos existen realmente
        error_log('RCP Level fields: ' . print_r(array_keys($level), true));

        $formatted_levels[] = array(
            'id'                => (int) $level['id'],
            'name'              => $level['name'],
            'description'       => $level['description'] ?? '',
            'access_level'      => isset($level['access_level']) ? (int) $level['access_level'] : null,
            'level'             => isset($level['level']) ? (int) $level['level'] : null, // Por si se llama 'level'
            'duration'          => (int) $level['duration'],
            'duration_unit'     => $level['duration_unit'] ?? 'month',
            'price'             => (float) $level['price'],
            'fee'               => (float) ($level['fee'] ?? 0),
            'maximum_renewals'  => (int) ($level['maximum_renewals'] ?? 0),
            'status'            => $level['status'],
            'role'              => $level['role'] ?? 'subscriber',
            'list_order'        => (int) ($level['list_order'] ?? 0),
        );
    }
    
    // Log para debug
    error_log('RCP Custom API: Returning ' . count($formatted_levels) . ' levels');
    
    return rest_ensure_response(array(
        'success' => true,
        'count'   => count($formatted_levels),
        'levels'  => $formatted_levels
    ));
}

/**
 * Agregar información del endpoint en el index de la API
 */
add_filter('rest_index', function($response) {
    $response->data['rcp_custom'] = array(
        'levels' => home_url('/wp-json/rcp-custom/v1/levels')
    );
    return $response;
});
